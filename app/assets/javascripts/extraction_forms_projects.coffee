# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  do ->

    $( 'ul#vertical-tabs' )
      .on 'cocoon:after-insert', ( e, new_section ) ->
        alert new_section

#    $( '.add-section a.add_fields' ).
#      data 'association-insertion-node', ( link ) ->
#        console.log link
#        console.log link.closest( 'ul#vertical-tabs' )
#        return link.closest( 'ul#vertical-tabs' ).find('li')



    return  # END do ->




  return  # END document.addEventListener 'turbolinks:load', ->
