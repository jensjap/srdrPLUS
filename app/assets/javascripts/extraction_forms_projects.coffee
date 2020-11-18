document.addEventListener 'DOMContentLoaded', ->
  return if $( '.extractions.work' ).length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  return unless $( '.extraction_forms_projects, .extractions' ).length > 0

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

      type1Type = tableRow.children( 'td[data-t1-type=""]' ).data('t1-type-id')
      type1Name = tableRow.children( 'td[data-t1-name=""]' ).text()
      type1Desc = tableRow.children( 'td[data-t1-description=""]' ).text()
      timepoints = []
      tableRow.find( 'td[data-timepoints=""] ul li' ).each ->
        timepoints.push({ name: $( this ).data( 'tp-name' ), unit: $( this ).data( 'tp-unit' ) })

      #type1Units = tableRow.children( 'td[data-t1-units=""]' ).text()

      # Find and fill the last input pair.
      efpsId = $( this ).data( 'sectionId' )

      inputFields = $( '.new-type1-fields-' + efpsId ).last()

      # Can't use .text() on form input/textarea -_-.
      inputFields.find( 'select[data-t1-type-input=""]' ).val( type1Type )
      inputFields.find( 'input[data-t1-name-input=""]' ).val( type1Name )
      inputFields.find( 'textarea[data-t1-description-input=""]' ).val( type1Desc )

      $('#timepoints-node tr')[1..].each ->
        $( this ).find( 'td.remove-tp-link a' ).trigger( 'click' )

      if timepoints.length > 1
        $( 'a.add-timepoint-link' ).trigger( 'click' ) for [2..timepoints.length]

      tp_elems = $('#timepoints-node tr')
      for tp, i in timepoints
        $( tp_elems[i] ).find( 'td.tp-name-input input' ).val(tp['name'])
        $( tp_elems[i] ).find( 'td.tp-unit-input input' ).val(tp['unit'])

      # Close the modal.
      $( this ).closest('.reveal').foundation( 'close' )

  # Attach listeners to select all within quality dimension section.
  $( 'input.select-all[type="checkbox"]' ).click ( e ) ->
    that = $( this )
    that.closest( 'table' ).find( 'input.quality-dimension-select' ).prop( 'checked', that.is( ':checked' ) )

  # Attach listeners to quality-dimension-* links.
  $( '#submit-quality-dimensions' ).click ( e ) ->
    a_qdqId   = []
    efpsId    = $( this ).data( 'extraction-forms-projects-section-id' )
    csrfToken = $( 'meta[name="csrf-token"]' ).attr('content')

    $( 'input.quality-dimension-select:checkbox:checked' ).each ->
      that   = $( this )
      qdqId  = that.attr( 'id' )
      a_qdqId.push( qdqId )

    if !Array.isArray(a_qdqId) or !a_qdqId.length
      # array does not exist, is not an array, or is empty
      # Close the modal.
      $( '#modal-' + efpsId ).foundation( 'close' )
    else
      # Spinner.
      $( '#modal-' + efpsId ).html( 'Submitting..' )
      post('/extraction_forms_projects_sections/' + efpsId + '/add_quality_dimension', { a_qdqId: a_qdqId, authenticity_token: csrfToken })

  $( '#extraction_forms_projects_section_extraction_forms_projects_sections_type1s_attributes_0_timepoint_name_ids' ).select2
    minimumInputLength: 0

  $( '#extraction_forms_projects_sections_type1_timepoint_name_ids' ).select2
    minimumInputLength: 0

  $(document).on "click", ".radio-deselector-btn", (e) ->
    dataRadioRemoveId = $(e.target).data('radio-remove-id')
    radioElements = $("*[data-radio-remove-id='#{dataRadioRemoveId}']")
    radioElements.removeAttr('checked')
    $(radioElements[0]).trigger("change");