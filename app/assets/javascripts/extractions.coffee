# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    $( '#outcome_subgroups_selector_eefpst1_id' ).change ( event ) ->
      $.ajax
        url: '/extractions_extraction_forms_projects_sections_type1s/' + this.value + '/get_results_subgroups'
        type: 'GET'
        dataType: 'script'
        error: -> alert 'Server busy'
        timeout: 5000
      return

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
