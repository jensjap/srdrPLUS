window.App ||= {}

App.init = ->
  # An example of loading on page to page loads.
  #$( "a, span, i, div" ).tooltip()

$( document ).on "turbolinks:load", ->
  App.init()
