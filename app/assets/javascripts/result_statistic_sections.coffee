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

        $( insertedItem ).find( '.links.add-comparate' ).each ->
          $( this ).find( 'a' ).click()

        # This creates a new cell at the end of the header row and moves the 'add comparison' link into it.
        # At the moment this isn't useful because we can't have the form span multiple row cells. Perhaps
        # using simple html form would work, but it doesn't seem to work with slim templating engine.
        #$( this ).closest( 'tr' ).append( $( '<th>' ).append( $( '.links.add-comparison' ) ) )

  return # END do ->
return # END turbolinks:load
