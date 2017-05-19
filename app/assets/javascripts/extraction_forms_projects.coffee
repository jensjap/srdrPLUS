# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  do ->




    $( '#questions' ).on 'cocoon:after-insert', ( e ) ->
      e.preventDefault()
      $( this ).find( 'form' ).find( 'input[type=submit]' ).removeClass( 'hide' )
      return

    $( '#questions' ).on 'cocoon:after-remove', ( e, item ) ->
      e.preventDefault()
      if $( '.nested-fields.add-question' ).length == 0
        $( this ).find( 'form' ).find( 'input[type=submit]' ).addClass( 'hide' )
      return

#
#    $( 'document' )
#      .on 'cocoon:after-insert', ( e, item ) ->
#        if newQuestion
#          $('.submit-new-question').removeClass('hide')
#
#      .on 'cocoon:after-remove', ( e, item ) ->
#        if newQuestion
#          $('.form-actions').removeClass('hide')
#        else
#          $('.form-actions').addClass('hide')


#    $( 'ul#vertical-tabs' )
#      .on 'cocoon:after-insert', ( e, new_section ) ->
#        console.log 'New section added'
#        Foundation.reInit 'tabs'


#    $( '.add-section a.add_fields' ).
#      data 'association-insertion-node', ( link ) ->
#        console.log link
#        console.log link.closest( 'ul#vertical-tabs' )
#        return link.closest( 'ul#vertical-tabs' ).find('li')



    return  # END do ->




  return  # END document.addEventListener 'turbolinks:load', ->
