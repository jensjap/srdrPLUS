# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  do ->

    #!!! We may want to allow the user to click on multiple rows.
    # This should trigger the cocoon link_to_add_association and fill in
    # automatically.
    $( '.fill-suggestion' ).click ( event ) ->
      if $( event.target ).is( 'td' )
        # Since event listener is on table and not the row we use event.target.
        tableRow = $( event.target ).closest( 'tr' )

        # Get name and description from this table row.
        type1Name = tableRow.children( 'td:nth-child(1)' ).text()
        type1Desc = tableRow.children( 'td:nth-child(2)' ).text()

        # Find and fill the last input pair.
        efpsId = $( this ).data( 'sectionId' )
        inputFields = $( '.new-type1-fields-' + efpsId ).last()

        # Can't use .text() on form input/textarea -_-.
        inputFields.find( 'input' ).val( type1Name )
        inputFields.find( 'textarea' ).val( type1Desc )

        # Close the modal.
        $( this ).closest('.reveal').foundation( 'close' )

    tabs = $( '#vertical-tabs' )
    if tabs.length
      console.log tabs
      tabs = $( '#vertical-tabs' ).foundation()
      firstTab = tabs.children( 'li' ).first()
      tabs.foundation( '_openTab', firstTab )

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
