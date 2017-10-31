# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    # Bind select2 to all type1 selections.
    $( 'select.hook-up-select2-to-type1-selections' ).each ->

      $( this ).select2
        minimumInputLength: 0
        ajax:
          url: '/api/v1/extraction_forms_projects_sections/' + $( this ).data( 'extraction-forms-projects-section-id' ) + '/type1s.json'
          dataType: 'json'
          delay: 250
          data: (params) ->
            q: params.term
            page: params.page
          processResults: (data, params) ->
            # The server may respond with params.page, set it to 1 if not.
            params.page = params.page || 1
            results: $.map(data.items, (i) ->
              id: i.id
              text: i.name
              description: i.description
              suggestion: i.suggestion
            )

      return  # END $( 'select.hook-up-select2-to-type1-selections' ).each ->

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
