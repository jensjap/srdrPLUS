# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    # Ajax call to filter the project list. We want to return a function here
    # to prevent it from being called immediately. Wrapper is to allow passing
    # param without immediate function invocation.
    filterProjectList = ( order ) ->
      ->
        $.get {
            url: '/projects/filter?q=' + $( '#project-filter' ).val() + '&o=' + order,
            dataType: 'script'
        }
        return

    # Everytime a user types into the search field we send an ajax request to
    # filter the list. Use delay to delay the call.
    $( '#project-filter' ).keyup ( e ) ->
      e.preventDefault()
      currentOrder = $( '.toggle-sort-order button.button.active' ).data( 'sortOrder' )
      delay filterProjectList( currentOrder ), 750
      return

    # There's a short flicker when the button gains focus which is ugly.
    # We prevent it by calling e.preventDefault(). However, this must happen
    # on mousedown because that's when an item gains focus.
    $( '.toggle-sort-order button' ).mousedown ( e ) ->
      e.preventDefault()
      if $( this ).hasClass( 'active' )
        return
      nextOrder = $( '.toggle-sort-order button.button.disabled' ).data( 'sortOrder' )
      # Since filterProjectList returns a function, we to call it immediately.
      filterProjectList( nextOrder )()
      return

    # Activates the search slider on the project index page.
    $( 'button.search' ).mousedown ( e ) ->
      e.preventDefault()
      $( '.search-field' ).toggleClass 'expand-search'
      $( '#project-filter' ).focus()
      return

    $( '.citation_select' ).select2
      ajax:
        url: '/api/v1/citations',
        dataType: 'json'
        delay: 250
        data: (params) ->
          console.log params
          q: params.term
          page: params.page || 1
        processResults: (data, params) ->
          # The server may respond with params.page, set it to 1 if not.
          params.page = params.page || 1
          results: $.map(data.items, (i) ->
            id: i.id
            text: i.name
          )
      width: '75%'

      # Cocoon listeners.
    $( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
      $( '.citation_select' ).select2
        ajax:
          url: '/api/v1/citations',
          dataType: 'json'
          delay: 250
          data: (params) ->
          console.log params
          q: params.term
          page: params.page || 1
        processResults: (data, params) ->
          # The server may respond with params.page, set it to 1 if not.
          params.page = params.page || 1
          results: $.map(data.items, (i) ->
            id: i.id
            text: i.name
          )
      width: '75%'
    return
#      # Cocoon listeners.
#      .on 'cocoon:before-insert', ( e, insertedItem ) ->
#        insertedItem.fadeIn 'slow'
#
#      .on 'cocoon:after-insert', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      .on 'cocoon:before-remove', ( e, insertedItem ) ->
#        #!!! This isnt' working. Immediately disappears.
#        $( this ).data 'remove-timeout', 1000
#        insertedItem.fadeOut 'slow'
#
#      .on 'cocoon:after-remove', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      # Abide listeners.
#      # Make form errors visible on the tab links.
#      .on 'invalid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( '<span style="color: red;">(*) Key Question(s)</span>' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( '<span style="color: red;">(*) Project Information</span>' )
#
#      .on 'valid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( 'Key Question(s)' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( 'Project Information' )

#    change = ->
#      $("form input, form textarea").change( ->
#        $('a').click( ->
#          confirm('Unsaved changes. Are you sure?')
#        )
#      )
#
#    $(document).ready(change)
#
#    # the page has been parsed and changed to the new version and on DOMContentLoaded
#    $(document).on('page:change', change)

#    # Set the field to display from the result set.
#    formatResultSelection = (result, container) ->
#      result.text
#
#    # Markup result.
#    formatResult = (result) ->
#      if result.loading
#        return result.text
#      markup = '<span>'
#      if ~result.text.indexOf 'Pirate'
#        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
#      if ~result.text.indexOf 'New item: '
#        #!!! Maybe add some styling.
#        markup += ''
#      markup += result.text
#      if result.suggestion
#        markup += ' (suggested by ' + result.suggestion.first_name + ')'
#      markup += '</span>'
#      markup
#
#    # Bind select2 to key question selection.
#    $( '#project_key_question_ids' ).select2
#      minimumInputLength: 0
#      ajax:
#        url: '/projects/' + gon.project_id + '/key_questions.json'
#        dataType: 'json'
#        delay: 250
#        data: (params) ->
#          q: params.term
#          page: params.page
#        processResults: (data, params) ->
#          # The server may respond with params.page, set it to 1 if not.
#          params.page = params.page || 1
#          results: $.map(data.items, (i) ->
#            id: i.id
#            text: i.name
#            suggestion: i.suggestion
#          )
#      escapeMarkup: (markup) ->
#        markup
#      templateResult: formatResult
#      templateSelection: formatResultSelection

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
