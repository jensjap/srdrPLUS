# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener 'turbolinks:load', ->

  do ->

    post = (path, params, method) ->
      method = method or 'post'
      # Set method to post by default if not specified.
      # The rest of this code assumes you are not using a library.
      # It can be made less wordy if you use one.
      form = document.createElement('form')
      form.setAttribute 'method', method
      form.setAttribute 'action', path
      for key of params
        if params.hasOwnProperty(key)
          hiddenField = document.createElement('input')
          hiddenField.setAttribute 'type', 'hidden'
          hiddenField.setAttribute 'name', key
          hiddenField.setAttribute 'value', params[key]
          form.appendChild hiddenField
      document.body.appendChild form
      form.submit()
      return

    #!!! We may want to allow the user to click on multiple rows.
    # This should trigger the cocoon link_to_add_association and fill in
    # automatically.
    $( '.fill-suggestion' ).click ( event ) ->
      if $( event.target ).is( 'td' )
        # Since event listener is on table and not the row we use event.target.
        tableRow = $( event.target ).closest( 'tr' )

        # Get name and description from this table row.
        type1Name = tableRow.children( 'td:nth-child(1)' ).text()
        type1Desc = tableRow.children( 'td:nth-child(2)' ).text()

        # Find and fill the last input pair.
        efpsId = $( this ).data( 'sectionId' )
        inputFields = $( '.new-type1-fields-' + efpsId ).last()

        # Can't use .text() on form input/textarea -_-.
        inputFields.find( 'input' ).val( type1Name )
        inputFields.find( 'textarea' ).val( type1Desc )

        # Close the modal.
        $( this ).closest('.reveal').foundation( 'close' )

#    # Open first tab with JavaScript.
#    tabs = $( '#vertical-tabs' )
#    if tabs.length
#      tabs = $( '#vertical-tabs' ).foundation()
#      firstTab = tabs.children( 'li' ).first()
#      tabs.foundation( '_openTab', firstTab )

    # Attach listeners to select all within quality dimension section.
    $( 'input.select-all[type="checkbox"]' ).click ( e ) ->
      that = $( this )
      that.closest( 'table' ).find( 'input.quality-dimension-select' ).prop( 'checked', that.is( ':checked' ) )

    # Attach listeners to quality-dimension-* links.
    $( '#submit-quality-dimensions' ).click ( e ) ->
      a_qdqId   = []
      efpsId    = undefined
      csrfToken = $( 'meta[name="csrf-token"]' ).attr('content')

      $( 'input.quality-dimension-select:checkbox:checked' ).each ->
        that   = $( this )
        efpsId = that.data( 'extraction-forms-projects-section-id' )
        qdqId  = that.attr( 'id' )
        a_qdqId.push( qdqId )

      post('/extraction_forms_projects_sections/' + efpsId + '/add_quality_dimension', { a_qdqId: a_qdqId, authenticity_token: csrfToken })
      console.log efpsId
      console.log a_qdqId
      console.log 'hurray!'

#    $( '[class^=add-quality-dimension-]' ).click ( e ) ->
#      e.preventDefault()
#      that      = $( this )
#      efpsId    = that.data( 'extraction-forms-projects-section-id' )
#      qdType    = that.data( 'quality-dimension-type' )
#      qdId      = that.data( 'quality-dimension-id' )
#      csrfToken = $( 'meta[name="csrf-token"]' ).attr('content')
#      post('/extraction_forms_projects_sections/' + efpsId + '/add_quality_dimension', { type: qdType, id: qdId, authenticity_token: csrfToken })

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
