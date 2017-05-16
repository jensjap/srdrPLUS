# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    # Set the field to display from the result set.
    formatResultSelection = (result, container) ->
      result.text

    # Markup result.
    formatResult = (result) ->
      if result.loading
        return result.text
      markup = '<span>'
      if ~result.text.indexOf 'Pirate'
        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
      if ~result.text.indexOf 'New item: '
        #!!! Maybe add some styling.
        markup += ''
      markup += result.text
      if result.suggestion
        markup += ' (suggested by ' + result.suggestion.first_name + ')'
      markup += '</span>'
      markup

    # Bind select2 to organization selection.
    $('#extraction_forms_projects_section_section_id').select2
      minimumInputLength: 0
      ajax:
        url: '/sections.json'
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
            suggestion: i.suggestion
          )
      escapeMarkup: (markup) ->
        markup
      templateResult: formatResult
      templateSelection: formatResultSelection

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
