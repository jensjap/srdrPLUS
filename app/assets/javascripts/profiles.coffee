# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  formatOrganizationSelection = (result, container) ->
    result.text

  formatOrganization = (result) ->
    if result.loading
      return result.text
    markup = ''
    if ~result.text.indexOf 'Pirate'
      markup += '<span><img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
    markup += result.text
    if result.suggestion
      markup += ' (suggested by user id: ' + result.suggestion.user_id + ')'
    markup += '</span>'
    markup

  $('#profile_degree_ids').select2
    closeOnSelect: false

  $('#profile_organization_id').select2
    minimumInputLength: 0
    ajax:
      url: '/organizations.json'
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
    templateResult: formatOrganization
    templateSelection: formatOrganizationSelection

  return # END document.addEventListener 'turbolinks:load', ->

