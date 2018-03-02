ocultaSecciones = ->
  $('.operacion').addClass 'hidden'

desactivaItemsMenu = ->
  $('a.m-item').removeClass 'is-active'

activaSeccion = (nombreSeccion) ->
  $("a.m-#{nombreSeccion}").on 'click', ->
    ocultaSecciones()
    $(".#{nombreSeccion}.operacion").removeClass 'hidden'
    desactivaItemsMenu()
    $(this).addClass 'is-active'

agregarAFN = ->
  $('.btn-crear').on 'click', ->
    if $('input.char').is ':checked'
      console.log 'transción con un simbolo'
      simbolo = $('.input.min-simbolo').val()
      $('.automatas').append """
        <li class="panel-block">
          <span class="regex">#{simbolo}</span>
        </li>
      """
    else
      console.log 'transción con un rango de simbolos'
      [minSimbolo, maxSimbolo] = [$('.input.min-simbolo').val(), $('.input.max-simbolo').val()].map (s) -> s.charCodeAt()

      rango = (String.fromCharCode(sim) for sim in [minSimbolo..maxSimbolo]).join '|'
      $('.automatas').append """
        <li class="panel-block">
          <span class="regex">#{rango}</span>
        </li>
      """

cambiarTipoAFN = ->
  $('.field.tipo-afn').on 'change', ->
    if $('input.rango').is ':checked'
      # Transción con un rango de simbolos
      field = $('.field.f-min-simbolo')
      field.removeClass 'has-addons'

      btn = $(field).find '.control.min-simbolo-add'
      btn.remove()

      sims = $('.columns.simbolos')
      sims.append """
        <div class="column col-max-simbolo">
          <div class="field">
            <div class="control">
              <input class="input max-simbolo" type="text" name="crear" maxlength="1" placeholder="Introduce el caracter máximo"/>
            </div>
          </div>
        </div>
      """
      $('.input.min-simbolo').attr 'placeholder', 'Introduce el carácter mínimo'

      $('.crear-AFN').append """
        <div class="field rango-btn">
          <div class="control">
            <a class="button is-primary btn-crear">Agregar</a>
          </div>
        </div>
      """
    else
      $('.col-max-simbolo').remove()
      $('.rango-btn').remove()

      field = $('.field.f-min-simbolo')
      $(field).addClass 'has-addons'
      $(field).append """
        <div class="control min-simbolo-add">
          <a class="button is-primary btn-crear">Agregar</a>
        </div>
      """
      $('.input.min-simbolo').attr 'placeholder', 'Intoduce un carácter'

    agregarAFN()

unirANFs = ->
  $('.btn-unir').on 'click', ->
    regexes = $('.unir.apila .regex').map(() -> $(this).text()).get().join('|')
    $('.unir.resultado').append """
      <li class="panel-block">
        <span class="regex">#{regexes}</span>
      </li>
    """
concatenarAFNs = ->
  $('.btn-concatenar').on 'click', ->
    regexes = $('.concatenar.apila .regex').map () ->
      regx = $(this).text()
      if '|¤┼?'.split('').some (closure) -> closure in regx
        return "(#{regx})"
      regx
    .get()
    .join('')
    $('.concatenar.resultado').append """
      <li class="panel-block">
        <span class="regex">#{regexes}</span>
      </li>
    """
kleenAFNs = ->
  $('.btn-asterisco').on 'click', ->
    regexes = $('.asterisco.apila .regex').map () ->
      regx = $(this).text()
      if regx.length > 1
        return "(#{regx})¤"
      "#{regx}¤"
    .get()

    $('.asterisco.resultado').append """
      <li class="panel-block">
        <span class="regex">#{regex}</span>
      </li>
    """ for regex in regexes by 1

positivaAFNs = ->
  $('.btn-positiva').on 'click', ->
    regexes = $('.positiva.apila .regex').map () ->
      regx = $(this).text()
      if regx.length > 1
        return "(#{regx})┼"
      "#{regx}┼"
    .get()

    $('.positiva.resultado').append """
      <li class="panel-block">
        <span class="regex">#{regex}</span>
      </li>
    """ for regex in regexes by 1

interrogacionAFNs = ->
  $('.btn-interrogacion').on 'click', ->
    regexes = $('.interrogacion.apila .regex').map () ->
      regx = $(this).text()
      if regx.length > 1
        return "(#{regx})?"
      "#{regx}?"
    .get()

    $('.interrogacion.resultado').append """
      <li class="panel-block">
        <span class="regex">#{regex}</span>
      </li>
    """ for regex in regexes by 1

validaAFNs = (regexes..., cadena) ->
  validaciones = []
  for regex in regexes by 1
    validaciones.push (new AFN).fromRegex(regex).cadenaValida cadena
  resultado = []

  validaciones.map (val) ->
    if val
      return '<span class="has-text-success">cadena valida :)</span>'

    '<span class="has-text-danger">cadena no valida :(</span>'

cadenaValidaAFNs = ->
  $('.btn-validar').on 'click', ->
    regexes = $('.validar.apila .regex').map(() -> $(this).text()).get()
    cadena = $('.input.cadena-validar').val()

    resultados = validaAFNs(regexes..., cadena)

    $('.validar.resultado').append """
      <li class="panel-block">
        #{regexes[i]} con "#{cadena}":&nbsp#{resultados[i]}
      </li>
    """ for i in [0..regexes.length - 1]


activaSeccion s for s in ['crear', 'unir', 'concatenar', 'asterisco', 'positiva', 'interrogacion', 'validar']
cambiarTipoAFN()
agregarAFN()
unirANFs()
concatenarAFNs()
kleenAFNs()
positivaAFNs()
interrogacionAFNs()
cadenaValidaAFNs()

adjustment = null

$('.draggable-both').sortable
  group: 'draggable-both'
  pullPlaceholder: false

  onDrop: ($item, container, _super) ->
    $clonedItem = $('<li/>').css height: 0
    $item.before $clonedItem
    $clonedItem.animate {'height': $item.height()}

    $item.animate $clonedItem.position(), ->
      $clonedItem.detach()
      _super $item, container

  onDragStart: ($item, container, _super) ->
    offset = $item.offset()
    pointer = container.rootGroup.pointer

    adjustment =
      left: pointer.left - offset.left
      top: pointer.top - offset.top

    _super $item, container

  onDrag: ($item, position) ->
    $item.css
      left: position.left - adjustment.left
      top: position.top - adjustment.top


#Cracion de la tabla, agrega fila a una tabla
$('#add-row').on 'click', (e) ->
  e.preventDefault()
  table_body = $(e.target).data().table
  if table_body
    add_row(table_body)

add_row = (table_body_element) ->
# Get some variables for the tbody and the row to clone.
  $tbody = $('#' + table_body_element)
  $rows = $($tbody.children('tr'))
  $cloner = $rows.eq(0)
  count = $rows.length

  # Clone the row and get an array of the inputs.
  $new_row = $cloner.clone()
  inputs = $new_row.find('.dyn-input')

  # Change the name and id for each input.
  $.each(inputs, (i, v) ->
    $input = $(v)

    # Find the label for input and adjust it.
    $label = $new_row.find("label[for='#{$input.attr('id')}']")
    $label.attr( {'for': $input.attr('id').replace(/\[.*\]/, "[#{count + 1}]")} )

    $input.attr({
      'name': $input.attr('name').replace(/\[.*\]/, "[#{count + 1}]"),
      'id': $input.attr('id').replace(/\[.*\]/, "[#{count + 1}]")
    })

    # Remove values and checks.
    $input.val('')
    checked = $input.prop('checked')
    if checked
      $input.prop('checked', false)
  )

  # Add the new row to the tbody.
  $tbody.append($new_row)


#imprimirTabla->
  #$( function (){
    #var data = prutabla() #no se como chingados agarrar la salida de tabla()

    #var table = arrayToTable(data, {
      #thead: true,
      #attrs: {class: 'tablaalv'}
    #})

    #$('body').append(table);

  #});
