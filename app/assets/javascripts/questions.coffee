# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    ###########################
    # Hide unnecessary options.
    multiSelect = ['1','2','3']

    $('.fieldset').on 'change', ->
      that = $(this)
      _value = that.find('select')[0].value

      if _value in multiSelect
        that.find('.field-options').hide()
        that.find('.field-options.field-option-type-1').show()
        that.find('.links').show()

      else
        that.find('.field-options').hide()
        that.find('.field-options.field-option-type-' + _value).show()
        that.find('.links').hide()

    $('.fieldset').trigger 'change'


    ###########################################
    # Hide first row and column if only 1 cell.

    hideHeaders = (_tableRows) ->
      _rowCnt = _tableRows.length
      _colCnt = _tableRows[0].cells.length

      console.log _rowCnt
      console.log _colCnt

      if _rowCnt == 2 and _colCnt == 2
        _tableRows.find('th:nth-child(-n+3)').hide()
        _tableRows.find('td:first-child').hide()

      return


    $('#step-two table').each ->

      _tableRows = $(this).find('tr')

      if _tableRows.length > 1
        hideHeaders(_tableRows)



    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
