# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    delay = do ->
      timer = 0
      ( callback, ms ) ->
        clearTimeout timer
        timer = setTimeout( callback, ms )
        return

    filterProjectList = ( order ) ->
      $.get {
          url: '/projects/filter?q=' + $( '#project-filter' ).val() + '&o=' + order,
          dataType: 'script'
        }
      return

    $( '#project-filter' ).keyup ( e ) ->
      e.preventDefault()
      currentOrder = $( '.toggle-sort-order button.button.active' ).data( 'sortOrder' )
      delay filterProjectList( currentOrder ), 250
      return

    $( '.toggle-sort-order button' ).click ( e ) ->
      e.preventDefault()
      nextOrder = $( '.toggle-sort-order button.button.disabled' ).data( 'sortOrder' )
      delay filterProjectList( nextOrder ), 250
      return

    return

  return
