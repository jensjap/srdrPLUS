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

        # Insert 'vs.' between the two comparate groups.
        $( '.nested-fields.comparate-groups' )
          .find( '.nested-fields.comparates' )
          .first()
          .after( $( '<div style="text-align: center; font-weight: normal;">vs.</div>' ) )

        if $( '.wac-comparate-fields' ).length == 2
          $( '.wac-comparate-fields:eq(1)' ).find( 'select option' ).filter( ->
            return this.text.includes( '(Baseline)' )
          ).attr('selected', true)

        $( '.links.add-comparison a' ).addClass( 'disabled' )
