document.addEventListener 'DOMContentLoaded', ->

  return unless $( '.invitations' ).length > 0

  do ->

    $( '.copy-to-clipboard' ).click copyToClipboardMessage