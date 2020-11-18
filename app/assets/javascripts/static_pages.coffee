# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'DOMContentLoaded', ->

  return unless $( '.static_pages' ).length > 0

  do ->

    scrollToTop = ->
      element = $( 'body' )
      offset = element.offset()
      offsetTop = offset.top # + 135  # 135px: height of AHRQ banner.
      $( 'html, body' ).animate { scrollTop: offsetTop }, 1000, 'swing'

    ## On document load scroll the AHRQ header out of sight ;)
    #element = $( 'body' )
    #offset = element.offset()
    #$( 'html, body' ).animate({ scrollTop: offset.top }, 1000, 'swing');

    # Make scroll-to-top button visible after scrolling down 100 pixels.
    $( document ).scroll ->
      if $( window ).scrollTop() > 100
        $( '.scroll-top-wrapper' ).addClass 'show'
      else
        $( '.scroll-top-wrapper' ).removeClass 'show'

    # Attach click handler to .scroll-top-wrapper btn to scroll to top.
    $( '.scroll-top-wrapper' ).click scrollToTop

    ## When topbar gets stuck to the top we want to visually highlight the
    #  signup link.
    $( '#responsive-menu' ).on( 'sticky.zf.stuckto:top', ->
      $( '#signup-link-id' ).addClass 'glow'
      return
    ).on 'sticky.zf.unstuckfrom:top', ->
      $( '#signup-link-id' ).removeClass 'glow'
      return