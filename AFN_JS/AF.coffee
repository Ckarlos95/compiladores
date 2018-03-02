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