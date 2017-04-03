# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->
  $('#profile_organization_id').change ->
    value = $(this).children(':selected').attr 'value'
    console.log value
    if value == '1'
      $('#suggested-organization-fields').removeClass 'hide'
    else
      $('#suggested-organization-fields').addClass 'hide'
    return
  return

