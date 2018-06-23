# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

#!!! This is buggy. When loading the page where the anchor is set, it'll have both open.
#    # Open first tab with JavaScript.
#      tabs = $( '#vertical-tabs' )
#      if tabs.length
#        tabs = $( '#vertical-tabs' ).foundation()
#        firstTab = tabs.children( 'li' ).first()
#        tabs.foundation( '_openTab', firstTab )

    # Adds a delay to calling a specific function.
    delay = do ->
      timer = 0
      ( callback, ms ) ->
        clearTimeout timer
        timer = setTimeout( callback, ms )
        return

    $( '#outcome_populations_selector_eefpst1_id' ).change ( event ) ->
      $.ajax
        url: '/extractions_extraction_forms_projects_sections_type1s/' + this.value + '/get_results_populations'
        type: 'GET'
        dataType: 'script'
        error: -> alert 'Server busy'
        timeout: 5000
      return

    #############################################################
    # Attach change event listener to text field to trigger save.
    $( '.work input[type="text"]' ).on 'input', ( e ) ->
      e.preventDefault()
      that = $( this )

      delay((() -> return console.log that.data()), 1000)

    ######################################################################
    # Attach click event to edit type1 from within extraction:consolidate.
    $( '.consolidate .edit-type1-link' ).click ( e ) ->
      e.preventDefault()
      e.stopPropagation()

      $this  = $( this )
      $modal = $( '#edit-type1-modal' )

      # Build urlString with endpoint to show the edit form 'edit_type1_across_extractions',
      # and query string:
      #   - type1_id
      #   - efps_id
      #   - extraction_ids
      urlString = 'edit_type1_across_extractions?'

      urlString = urlString.concat 'type1_id='
      urlString = urlString.concat $this.data( 'type1-id' )

      urlString = urlString.concat '&efps_id='
      urlString = urlString.concat $this.data( 'efps-id' )

      $( $this.data( 'extraction-ids' ) ).each ( idx, elem ) ->
        urlString = urlString.concat '&extraction_ids[]='
        urlString = urlString.concat elem

      $.ajax( urlString ).done ( resp ) ->
        $modal.html( resp ).foundation 'open'
        return

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
