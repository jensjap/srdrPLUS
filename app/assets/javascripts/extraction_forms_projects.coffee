# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  do ->

    $( '.fill-suggestion' ).click ( event ) ->
      if ( $( event.target ).is( 'td' ) )
        row = $( event.target ).parent 'tr'
        name = row.children( 'td' )[0].textContent
        description = row.children( 'td' )[1].textContent

        # Find and fill the last input pair
        efpsId = $( this ).data('efpsId')
        input_fields = $( $( '.new-suggestion-fields-' + efpsId ) ).last()

        $( input_fields.children( 'div.input' )[0] ).children( 'input' ).val( name )
        $( input_fields.children( 'div.input' )[1] ).children( 'textarea' ).val( description )
        $( this ).closest('.reveal').foundation( 'close' )

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
