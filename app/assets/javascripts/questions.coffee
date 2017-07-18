# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

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

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
