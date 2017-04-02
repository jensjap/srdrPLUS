# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
scrollToTop = ->
  verticalOffset = if typeof verticalOffset != 'undefined' then verticalOffset else 0
  element = $( 'body' )
  offset = element.offset()
  offsetTop = offset.top # + 135  # 135px: height of AHRQ banner.
  $( 'html, body' ).animate { scrollTop: offsetTop }, 1000, 'swing'
  return

document.addEventListener 'turbolinks:load', ->
#  # On document load scroll the AHRQ header out of sight ;)
#  element = $( 'body' )
#  offset = element.offset()
#  $( 'html, body' ).animate({ scrollTop: offset.top }, 1000, 'swing');

  # Make scroll-to-top button visible after scrolling down 100 pixels.
  $( document ).on 'scroll', ->
    if $( window ).scrollTop() > 235
      $( '.scroll-top-wrapper' ).addClass 'show'
    else
      $( '.scroll-top-wrapper' ).removeClass 'show'
    return
  $( '.scroll-top-wrapper' ).on 'click', scrollToTop
  return
