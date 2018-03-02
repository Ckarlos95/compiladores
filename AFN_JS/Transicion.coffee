class Transicion
  constructor: (simbolos..., @estado) ->
    if simbolos.length is 1
      # Una transicion con un solo caracter
      @minSimbolo = @maxSimbolo = simbolos[0].charCodeAt()
    else
      # Transicion con un rango de caracteres
      [@minSimbolo, @maxSimbolo] = [simbolos...].map (char) -> char.charCodeAt()