# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    if gon.tip_of_the_day
      toastr.info(gon.tip_of_the_day, 'Tip Of The Day', {
          'timeOut': '10000',
          'progressBar': true })

    return

  return
