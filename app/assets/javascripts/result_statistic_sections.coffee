# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->

    $( '.links.add-comparison' )

      .on 'cocoon:before-insert', ->
        $( this ).hide()

      .on 'cocoon:after-insert', ( e, insertedItem ) ->
        $( insertedItem ).find( '.links.add-comparate-group a' ).click()
        $( insertedItem ).find( '.links.add-comparate-group a' ).click()
        $( '.links.add-comparate-group a' ).hide()
        $( '.add-comparate' ).each ->
          $( this ).find( 'a' ).click()

  return # END do ->
return # END turbolinks:load
