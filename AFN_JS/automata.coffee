class Transicion
  constructor: (simbolos..., @estado) ->
    if simbolos.length is 1
      # Una transicion con un solo caracter
      @minSimbolo = @maxSimbolo = simbolos[0].charCodeAt()
    else
      # Transicion con un rango de caracteres
      [@minSimbolo, @maxSimbolo] = [simbolos...].map (char) -> char.charCodeAt()
class Estado
  @idEstado : 0

  constructor: ->
    @aceptacion = false
    @transiciones = []
    Estado.idEstado+=1
    @idEdo = Estado.idEstado

  agregaTransicion: (simbolos..., estado) ->
    @transiciones.push new Transicion simbolos..., estado

  estadosCon: (simbolo) ->
    t.estado for t in @transiciones when t.minSimbolo <= simbolo.charCodeAt() <= t.maxSimbolo by 1

#import Estado from './Estado'

Array::unique = ->
  # Retorna arreglo con valores unicos
  # No util para array de objetos
  output = {}
  output[@[key]] = @[key] for key in [0...@length] by 1
  value for key, value of output

Array::compare = (array) ->
  @length is array.length and @every (elem, i) -> elem is array[i]

class AF
  @Token

  constructor: (simbolos...) ->
    if simbolos.length is 0
      # AF vacio
      return @vacio()

    if simbolos.length is 1
      # AF con transicion para un solo simbolo
      @alfabeto = simbolos[0]
    else
      # AF con transicion para un rango de simbolos
      @alfabeto = [simbolos[0].charCodeAt()..simbolos[1].charCodeAt()]
        .map((sim) -> String.fromCharCode(sim))
        .join('')

    @edoInicial = new Estado

    edoFinal = new Estado
    edoFinal.aceptacion = true
    @edoInicial.agregaTransicion simbolos..., edoFinal

    @estados = [@edoInicial, edoFinal]
    @edosAceptacion = [edoFinal]

  setToken: (token) ->
    @Token = token

  getToken: ->
    return @Token

  vacio: ->
    @alfabeto = ''
    @estados = []
    @edosAceptacion = []
    @edoInicial = null

    return this

  agregaEstado: (estado) ->
    @estados.push estado if estado not in @estados

  uneEstados: (otrosEstados) ->
    @agregaEstado e for e in otrosEstados by 1
    @estados

  uneAlfabetos: (otroAlfabeto) ->
    @alfabeto = (@alfabeto + otroAlfabeto).split('').unique().sort().join('')
class AFN extends AF
  EPS: '\u0000'

  constructor: (simbolos...) ->
    super simbolos...

  uneAFN: (otroAFN) ->
    nuevoInicial = new Estado
    nuevoFinal = new Estado

    nuevoInicial.agregaTransicion @EPS, @edoInicial
    nuevoInicial.agregaTransicion @EPS, otroAFN.edoInicial

    for edoAcept in [@edosAceptacion..., otroAFN.edosAceptacion...] by 1
      edoAcept.agregaTransicion @EPS, nuevoFinal
      edoAcept.aceptacion = false

    nuevoFinal.aceptacion = true

    @estados.push [nuevoInicial, nuevoFinal]...
    @edoInicial = nuevoInicial
    @edosAceptacion = [nuevoFinal]

    @uneEstados otroAFN.estados
    @uneAlfabetos otroAFN.alfabeto

    return this

  unionAnalisisLex: (otrosAFN...) ->
    afn = new AFN()
    nuevoInicial = new Estado
    afn.edoInicial = nuevoInicial
    for afns in otrosAFN by 1
      nuevoInicial.agregaTransicion @EPS, afns.edoInicial
      afn.uneAlfabetos afns.alfabeto
      afn.uneEstados afns.estados
      for edoFinal in afns.edosAceptacion by 1
        afn.edosAceptacion.push edoFinal
    afn.estados.push nuevoInicial

    return afn

  concatenaAFN: (otroAFN) ->
    for edoAcept in @edosAceptacion by 1
      edoAcept.transiciones = otroAFN.edoInicial.transiciones
      edoAcept.aceptacion = false

    @edosAceptacion = otroAFN.edosAceptacion

    @uneEstados otroAFN.estados.filter (edo) -> edo isnt otroAFN.edoInicial
    @uneAlfabetos otroAFN.alfabeto

    return this

  cerraduraMas: ->
    nuevoInicial = new Estado
    nuevoFinal = new Estado

    nuevoInicial.agregaTransicion @EPS, @edoInicial # Primer transicion Epsilon

    for estado in @edosAceptacion by 1
      estado.agregaTransicion @EPS, nuevoFinal
      estado.agregaTransicion @EPS, @edoInicial
      estado.aceptacion = false

    nuevoFinal.aceptacion = true
    @edoInicial = nuevoInicial
    @edosAceptacion = [nuevoFinal]
    @estados.push [nuevoInicial, nuevoFinal]...

    return this

  cerraduraAsterisco: ->
    @cerraduraMas()
    @edoInicial.agregaTransicion @EPS, edoAcept for edoAcept in @edosAceptacion by 1

    return this

  cerraduraInterrogacion: ->
    nuevoInicial = new Estado
    nuevoFinal = new Estado

    nuevoInicial.agregaTransicion @EPS, @edoInicial
    nuevoInicial.agregaTransicion @EPS, nuevoFinal

    for estado in @edosAceptacion
      estado.agregaTransicion @EPS, nuevoFinal
      estado.aceptacion = false

    nuevoFinal.aceptacion = true
    @edoInicial = nuevoInicial
    @edosAceptacion = [nuevoFinal]
    @estados.push [nuevoInicial, nuevoFinal]...

    return this

  cerraduraEpsilon: (estados...) ->
    edoActual = null
    resultado = []
    stack = []

    for estado in estados by 1
      stack.push estado
      while stack.length
        edoActual = stack.pop()

        unless edoActual in resultado
          resultado.push edoActual
          stack.push edoActual.estadosCon(@EPS)...

    resultado

  mover: (estados..., simbolo) ->
    resultado = []
    resultado.push estado.estadosCon(simbolo)... for estado in estados by 1
    resultado

  irA: (estados..., simbolo) ->
    @cerraduraEpsilon(@mover(estados..., simbolo)...)

  cadenaValida: (cadena) ->
    # Se aplica cerradura Epsilon al estado inicial del automata
    # y se parte de ahi
    conjuntoEdos = @cerraduraEpsilon @edoInicial

    for simbolo in cadena.split('') by 1
      conjuntoEdos = @irA conjuntoEdos..., simbolo

      # La cadena no es valida cuando la operacion IrA en
      # algun momento retorna un conjunto vacio
      return false unless conjuntoEdos.length

    return true for edoAcept in @edosAceptacion when edoAcept in conjuntoEdos by 1

    false

  toAFD: ->
    nuevoAFD = new AFD
    afdEdoInicial = new Estado
    nuevoAFD.edoInicial = afdEdoInicial
    nuevoAFD.estados.push nuevoAFD.edoInicial

    contenedorEstados = [@cerraduraEpsilon @edoInicial]

    indiceEdoActual = 0

    loop
      edoActual = nuevoAFD.estados[indiceEdoActual]
      edosActuales = contenedorEstados[indiceEdoActual]

      for simboloActual in @alfabeto by 1
        operIrA = @irA edosActuales..., simboloActual

        unless operIrA.length
          # Si el resultado de la operacion IrA es un conjunto vacio
          edoActual.agregaTransicion simboloActual, AFD::EDO_ERROR
          continue

        edoALlegar = new Estado

        indiceEdoALlegar = contenedorEstados.findIndex (conjuntoEdos) -> conjuntoEdos.compare operIrA
        if indiceEdoALlegar > -1
          # El conjunto de estados ya fue generado
          edoALlegar = nuevoAFD.estados[indiceEdoALlegar]
          edoActual.agregaTransicion simboloActual, edoALlegar
          continue

        else
          for edoAcept in @edosAceptacion by 1
            if edoAcept in operIrA
              edoALlegar.aceptacion = true
              nuevoAFD.edosAceptacion.push edoALlegar
              break

          edoActual.agregaTransicion simboloActual, edoALlegar
          nuevoAFD.estados.push edoALlegar
          contenedorEstados.push operIrA

      indiceEdoActual += 1

      break if indiceEdoActual >= contenedorEstados.length

    nuevoAFD.alfabeto = @alfabeto
    nuevoAFD.estados.push AFD::EDO_ERROR

    nuevoAFD

  fromRegex: (regex) ->
    stack = [[]]

    for simbolo in regex
      if simbolo is '('
        stack.push []
      else if simbolo is ')'
        subRegex = stack.pop()
        stack[stack.length - 1].push @fromRegex subRegex
      else
        stack[stack.length - 1].push simbolo

    for i in [0...stack[stack.length - 1].length]
      item = stack[stack.length - 1][i]
      if typeof(item) is 'string' and item not in '|┼¤?'
        stack[stack.length - 1][i] = new AFN(item)

    while '¤' in stack[stack.length - 1]
      index = stack[stack.length - 1].indexOf '¤'
      stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraAsterisco()
      stack[stack.length - 1].splice index, 1

    while '┼' in stack[stack.length - 1]
      index = stack[stack.length - 1].indexOf '┼'
      stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraMas()
      stack[stack.length - 1].splice index, 1

    while '?' in stack[stack.length - 1]
      index = stack[stack.length - 1].indexOf '?'
      stack[stack.length - 1][index - 1] = stack[stack.length - 1][index - 1].cerraduraInterrogacion()
      stack[stack.length - 1].splice index, 1

    i = 0
    while i < stack[stack.length - 1].length - 1
      unless stack[stack.length - 1][i + 1] is '|' or stack[stack.length - 1][i] is '|'
        stack[stack.length - 1][i] = stack[stack.length - 1][i].concatenaAFN stack[stack.length - 1][i + 1]
        stack[stack.length - 1].splice i + 1, 1
      else
        i++

    result = stack[stack.length - 1][0]
    for i in [1...stack[stack.length - 1].length]
      if stack[stack.length - 1][i] isnt '|'
        result = result.uneAFN stack[stack.length - 1][i]

    result
class AFD extends AF
  EDO_ERROR: new Estado

  constructor: (simbolos...) ->
    super simbolos...

  mover: (estado, simbolo) ->
    estado.estadosCon(simbolo)[0]

  cadenaValida: (cadena) ->
    simbolos = cadena.split('')
    edoActual = @mover @edoInicial, simbolos.shift()

    for simbolo in simbolos by 1
      return false unless simbolo in @alfabeto

      edoActual = @mover edoActual, simbolo

      return false if edoActual is @EDO_ERROR

    return true if edoActual in @edosAceptacion

    false

  tabla: ->
    @table = [["",@alfabeto.split("")...]]
    for estado in @estados by 1
      if estado.aceptacion is true
        fila = [estado.idEdo + "*"]
      else
        fila = [estado.idEdo + ""]
      continue if estado is @EDO_ERROR
      for simbolo in @alfabeto by 1
        edollegar = @mover(estado,simbolo)
        if edollegar is @EDO_ERROR
          fila.push -1
        else
          fila.push edollegar.idEdo
      @table.push fila
    @table

  imprimirTabla: ()->
    console.log "\nTabla del AFD"
    for fila in @table by 1
      console.log fila

