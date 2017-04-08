# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    scrollToTop = ->
      element = $( 'body' )
      offset = element.offset()
      offsetTop = offset.top # + 135  # 135px: height of AHRQ banner.
      $( 'html, body' ).animate { scrollTop: offsetTop }, 1000, 'swing'
      return

    ## On document load scroll the AHRQ header out of sight ;)
    #element = $( 'body' )
    #offset = element.offset()
    #$( 'html, body' ).animate({ scrollTop: offset.top }, 1000, 'swing');

    # Make scroll-to-top button visible after scrolling down 100 pixels.
    $( document ).on 'scroll', ->
      if $( window ).scrollTop() > 100
        $( '.scroll-top-wrapper' ).addClass 'show'
      else
        $( '.scroll-top-wrapper' ).removeClass 'show'
      return

    # Attach click handler to .scroll-top-wrapper btn to scroll to top.
    $( '.scroll-top-wrapper' ).on 'click', scrollToTop

    return

