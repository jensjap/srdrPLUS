# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

bind_srdr20_saving_mechanism = () ->
  return if $('body.sd_meta_data').length == 0

  timers = {}

  submitForm = ( form ) ->
    ->
      form = $('#sd-meta-form')[0]
      formData = new FormData(form)

      $.ajax({
        type: "PATCH",
        url: $('#sd-meta-form')[0].action,
        data: formData,
        async: true,
        contentType: false,
        processData: false
      })

  # Select Drop Down and Radio
  $( 'form' ).change ( e ) ->
    e.preventDefault()

    $form = $( this ).closest( 'form' )

    # Use this to keep track of the different timers.
    formId = $form.attr( 'id' )

    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )

    if formId of timers
      clearTimeout( timers[formId] )
    timers[formId] = setTimeout( submitForm( $form ), 750 )


  # Autogrow Text Field to fit the content.
  $( 'form' ).each () ->
    while $(this).outerHeight() < @scrollHeight + parseFloat($(this).css('borderTopWidth')) + parseFloat($(this).css('borderBottomWidth'))
      $(this).height $(this).height() + 1

  # Text Field.
  $( 'form' ).keyup ( e ) ->
    e.preventDefault()

    # Ignore 'keyup' for a list of keys.
    code = e.keyCode || e.which;
    # 9: tab; 16: shift; 37: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 91: cmd
    if code in [9, 16, 18, 37, 38, 39, 40, 91]
      return

    $form = $( this ).closest( 'form' )

    # Use this to keep track of the different timers.
    formId = $form.attr( 'id' )

    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )

    if formId of timers
      clearTimeout( timers[formId] )
    timers[formId] = setTimeout( submitForm( $form ), 750 )

    # the following will help the text expand as typing takes place
    while $(this).outerHeight() < @scrollHeight + parseFloat($(this).css('borderTopWidth')) + parseFloat($(this).css('borderBottomWidth'))
      $(this).height $(this).height() + 1

document.addEventListener 'turbolinks:load', ->
  do ->
    bind_srdr20_saving_mechanism()

    # Set the field to display from the result set.
    formatResultSelection = ( result, container ) ->
      result.text

    # Markup result.
    formatResult = ( result ) ->
      if result.loading
        return result.text
      markup = '<span>'
      if ~result.text.indexOf 'Pirate'
        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
      if ~result.text.indexOf 'New item: '
        #!!! Maybe add some styling.
        markup += ''
      markup += result.text
      if result.suggestion
        markup += ' (suggested by ' + result.suggestion.first_name + ')'
      markup += '</span>'
      markup

    init_select2 = (selector, url) ->
      $( selector ).select2
        minimumInputLength: 0
        ajax:
          url: url,
          dataType: 'json'
          delay: 250
          data: ( params ) ->
            q: params.term
            page: params.page
          processResults: ( data, params ) ->
            # The server may respond with params.page, set it to 1 if not.
            params.page = params.page || 1
            results: $.map( data.items, ( i ) ->
              id: i.id
              text: i.name
              suggestion: i.suggestion
            )
        escapeMarkup: ( markup ) ->
          markup
        templateResult: formatResult
        templateSelection: formatResultSelection

    init_select2("#sd_meta_datum_funding_source_ids", '/funding_sources')
    init_select2("#sd_meta_datum_key_question_type_ids", '/key_question_types')
    init_select2(".sd_search_database", '/sd_search_databases')
    init_select2(".key_question", '/key_questions')
    init_select2(".key_question_type", '/key_question_types')
    sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id')
    init_select2(".sd_picods_key_question", "/sd_key_questions?sd_meta_datum_id=#{sd_meta_datum_id}")
    init_select2(".sd_picods_type", '/sd_picods_types')

    $( "form" ).on "cocoon:after-insert", (_, row) ->
      sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id')
      init_select2($( row ).find( ".sd_search_database" ), '/sd_search_databases')
      init_select2($( row ).find( ".key_question" ), '/key_questions')
      init_select2($( row ).find( ".key_question_type" ), '/key_question_types')
      init_select2($( row ).find( ".sd_picods_key_question" ), "/sd_key_questions?sd_meta_datum_id=#{sd_meta_datum_id}")

    $( "a[data-remote]" ).on "ajax:success",  ( event ) ->
      $( this ).parent().closest( 'div' ).fadeOut();
    return  # END do ->
  return  # END document.addEventListener 'turbolinks:load', ->
