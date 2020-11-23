document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  return unless $( '.questions, .extractions, .extraction_forms_projects.build' ).length > 0

  ###########################
  # Hide unnecessary options.
  multiSelect = ['Checkbox (select multiple)', 'Dropdown (select one)', 'Radio (select one)', 'Select one (with write-in option)', 'Select multiple (with write-in option)']
  allowsFollowup = ['Checkbox (select multiple)', 'Radio (select one)']

  $('.fieldset').on 'change', ->
    that = $(this)
    that.find('.field-options').hide()
    that.find('.links').hide()
    _value = that.find('select').children(':selected').text()

    if _value in multiSelect
      that.find('.field-options.field-option-type-answer_choice').show()
      that.find('.links').show()
      if _value in allowsFollowup
        that.find('.followup_container').css('visibility', 'visible')
      else
        that.find('.followup_container').css('visibility', 'hidden')

    else if _value == 'Text Field (alphanumeric)'  # Text.
      that.find('.field-options.field-option-type-min_length').show()
      that.find('.field-options.field-option-type-max_length').show()

    else if _value == 'Numeric Field (numeric)'  # Numeric.
      that.find('.field-options.field-option-type-additional_char').show()
      that.find('.field-options.field-option-type-min_value').show()
      that.find('.field-options.field-option-type-max_value').show()

    else if _value == 'numeric_range'  # Numeric range.
      that.find('.field-options.field-option-type-min_value').show()
      that.find('.field-options.field-option-type-max_value').show()

    else if _value == 'scientific'  # Scientific.
      that.find('.field-options.field-option-type-min_value').show()
      that.find('.field-options.field-option-type-max_value').show()
      that.find('.field-options.field-option-type-coefficient').show()
      that.find('.field-options.field-option-type-exponent').show()

  $('.fieldset').trigger 'change'

  ###########################################
  # Hide first row and column if only 1 cell.
  hideHeaders = (_tableRows) ->
    _rowCnt = _tableRows.length
    _colCnt = _tableRows[0].cells.length

    if _rowCnt == 2
      _tableRows.find('td:first-child, th:first-child').hide()

    if _colCnt == 2
      _tableRows.find('th:nth-child(-n+3)').hide()


  $('.clean-table table, table.dependency-table').each ->
    _tableRows = $(this).find('tr')

    if _tableRows.length > 1
      hideHeaders(_tableRows)

  #########################################################################
  # A little hacky to get the form to save before we hit the add column or
  # add row button. This is so we don't lose any content already written to
  # the form.
  $( '#add_column_link' ).click ( event ) ->
    event.preventDefault()
    $form = $( "form[id^='edit_question_']" )
    $form.ajaxSubmit
      dataType: 'script'
      success: ->
        $( '#add_column_button' ).click()
        return
    return false

  $( '#add_row_link' ).click ( event ) ->
    event.preventDefault()
    $form = $( "form[id^='edit_question_']" )
    $form.ajaxSubmit
      dataType: 'script'
      success: ->
        $( '#add_row_button' ).click()
        return
    return false