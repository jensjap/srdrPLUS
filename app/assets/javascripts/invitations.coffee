# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->
    $( '.copy-to-clipboard' ).click ( e ) ->
      e.preventDefault()
      copyToClipboard( $( this ).text() )
      $( this ).append( '<span class="copied-message" style="color: green; font-size: 0.8em;"> Copied!</span>' )
      $( '.copied-message' ).delay( 800 ).fadeOut( 400 ).queue( -> $( this ).remove() )

      return
