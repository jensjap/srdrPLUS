# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    # Adds a delay to calling a specific function.
    delay = do ->
      timer = 0
      ( callback, ms ) ->
        clearTimeout timer
        timer = setTimeout( callback, ms )
        return

    # Ajax call to filter the project list.
    filterProjectList = ( order ) ->
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
      delay filterProjectList( currentOrder ), 500
      return

    # There's a short flicker when the button gains focus which is ugly.
    # We prevent it by calling e.preventDefault(). However, this must happen
    # on mousedown because that's when an item gains focus.
    $( '.toggle-sort-order button' ).mousedown ( e ) ->
      e.preventDefault()
      if $( this ).hasClass( 'active' )
        return
      nextOrder = $( '.toggle-sort-order button.button.disabled' ).data( 'sortOrder' )
      delay filterProjectList( nextOrder ), 500
      return

    # Activates the slider.
    $( 'button.search' ).mousedown ( e ) ->
      e.preventDefault()
      $( '.search-field' ).toggleClass 'expand-search'
      $( '#project-filter' ).focus()
      return

    return

  return
