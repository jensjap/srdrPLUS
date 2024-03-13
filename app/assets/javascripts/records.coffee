document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  return if $('body.public_data.show').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = () ->
  timers = {}
  error_timers = {}

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

      # Set error_timers.
      setTimeoutError({ duration: 10000, formId: formId })

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )

  checkDirty = ( element ) ->
    if element.closest( 'form' ).classList.contains( 'dirty' )
      toastr.error(
        'You seem to be offline or the server is currently unresponsive.
         Please ensure your network is operational or try again later.',
        'Warning: Error detected!'
      )

  setTimeoutError = ( params ) ->
    duration = params.duration
    formId = params.formId
    element = event.target

    if formId of error_timers
      clearTimeout( error_timers[formId] )

    error_timers[formId] = setTimeout(checkDirty.bind( null, element ), duration)
