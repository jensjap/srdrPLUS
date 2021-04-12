document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = () ->
  timers = {}

  submitForm = ( form ) ->
    ->
      form.submit()

  # Select Drop Down and Radio
  $( document ). on 'input propertychange', 'form.edit_extractions_extraction_forms_projects_sections_question_row_column_field select, form.edit_record select, form.edit_record input[type="checkbox"], form.edit_record input[type="radio"], form.edit_record input[type="number"]', ( e ) ->
    e.preventDefault()

    valueChanged = false

    if e.type == 'propertychange'
      valueChanged = e.originalEvent.propertyName == 'value'
    else
      valueChanged = true

    if valueChanged
      $form = $( this ).closest( 'form' )

      # Use this to keep track of the different timers.
      formId = $form.attr( 'id' )

      # Mark form as 'dirty'.
      $form.addClass( 'dirty' )

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )

    #!!! jens-2021-02-20: Crashes some work forms (infinite loop).
    # Autogrow Text Field to fit the content.
    # $( 'form.edit_record input, form.edit_record textarea' ).each () ->
    #   while $(this).outerHeight() < @scrollHeight + parseFloat($(this).css('borderTopWidth')) + parseFloat($(this).css('borderBottomWidth'))
    #     $(this).height $(this).height() + 1

  # Text Field.
  $( document ).on 'input propertychange', 'form.edit_record input, form.edit_record textarea', ( e ) ->
    e.preventDefault()

    valueChanged = false

    if e.type == 'propertychange'
      valueChanged = e.originalEvent.propertyName == 'value'
    else
      valueChanged = true

    if valueChanged
      $form = $( this ).closest( 'form' )

      # Use this to keep track of the different timers.
      formId = $form.attr( 'id' )

      # Mark form as 'dirty'.
      $form.addClass( 'dirty' )

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )

      #!!! jens-2021-02-20: Crashes some work forms (infinite loop).
      # the following will help the text expand as typing takes place
      # while $(this).outerHeight() < @scrollHeight + parseFloat($(this).css('borderTopWidth')) + parseFloat($(this).css('borderBottomWidth'))
      #   $(this).height $(this).height() + 1