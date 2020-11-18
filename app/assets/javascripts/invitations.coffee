# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'DOMContentLoaded', ->

  return unless $( '.invitations' ).length > 0

  do ->

    $( '.copy-to-clipboard' ).click copyToClipboardMessage