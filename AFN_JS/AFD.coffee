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
