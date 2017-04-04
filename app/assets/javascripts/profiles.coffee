# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  $('#profile_degree_ids').select2({
    closeOnSelect: false
    })

  $('#profile_organization_id').select2()

  return # END document.addEventListener 'turbolinks:load', ->

