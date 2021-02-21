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
  $( 'form.edit_extractions_extraction_forms_projects_sections_question_row_column_field select, form.edit_record select, form.edit_record input[type="checkbox"], form.edit_record input[type="radio"], form.edit_record input[type="number"]' ).change ( e ) ->
    e.preventDefault()

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
  $( 'form.edit_record input, form.edit_record textarea' ).keyup ( e ) ->
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

    #!!! jens-2021-02-20: Crashes some work forms (infinite loop).
    # the following will help the text expand as typing takes place
    # while $(this).outerHeight() < @scrollHeight + parseFloat($(this).css('borderTopWidth')) + parseFloat($(this).css('borderBottomWidth'))
    #   $(this).height $(this).height() + 1