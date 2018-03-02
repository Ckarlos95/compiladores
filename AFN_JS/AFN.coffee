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