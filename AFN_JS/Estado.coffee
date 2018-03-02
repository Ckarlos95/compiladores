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
