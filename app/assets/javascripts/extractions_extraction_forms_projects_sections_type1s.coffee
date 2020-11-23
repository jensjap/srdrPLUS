document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  return unless $( '.extractions_extraction_forms_projects_sections_type1s' ).length > 0

  $( '.edit_extractions_extraction_forms_projects_sections_type1 .add_fields' )
  .data( 'association-insertion-method', 'append' )
  .data( 'association-insertion-node', ( link ) ->
    return link.closest( '#populations, #timepoints' ).find( 'tbody' ) )

  formatTimepoint = ( timepoint ) ->
    if timepoint.loading
      return timepoint.text
    markup =  '<div class="select2-timepoint" style="border: 1px solid grey; border-radius: 10px; padding: 5px;">'
    markup += '  <div class="select2-timepoint__name">Name: ' + timepoint.text + '</div>'
    if timepoint.unit
      markup += '  <div class="select2-timepoint__unit">Unit: ' + timepoint.unit + '</div>'
    else
      markup += '  <div class="select2-timepoint__unit">Unit: </div>'
    markup += '</div>'
    markup

  formatTimepointSelection = ( timepoint ) ->
    timepoint.text

  $( '#extractions_extraction_forms_projects_sections_type1_row_timepoint_name_id' ).select2
    minimumInputLength: 0
    closeOnSelect: true
    ajax:
      url: '/api/v1/timepoint_names'
      dataType: 'json'
      delay: 250
      data: ( params ) ->
        {
          q: params.term
          page: params.page
        }
      processResults: ( data, params ) ->
        # The server may respond with params.page, set it to 1 if not.
        params.page = params.page or 1
        {
          results: $.map( data.items, ( i ) ->
            id: i.id
            text: i.name
            unit: i.unit
          )
        }
      cache: true
    placeholder: 'Search for an existing Timepoint'
    escapeMarkup: ( markup ) ->
      markup
    templateResult: formatTimepoint
    templateSelection: formatTimepointSelection

    $(".dropdown_with_writein").select2({
      tags: true
    });