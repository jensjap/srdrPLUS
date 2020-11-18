document.addEventListener 'DOMContentLoaded', ->
  return if $( '.extractions.work' ).length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  $( '.links.add-comparison' )

    .on 'cocoon:before-insert', ->
      $( this ).hide()

    .on 'cocoon:after-insert', ( e, insertedItem ) ->
      $( insertedItem ).find( '.links.add-comparate-group a' ).click()
      $( insertedItem ).find( '.links.add-comparate-group a' ).click()
      $( '.links.add-comparate-group a' ).hide()
      $( insertedItem ).find( '.links.add-comparate' ).each ->
        $( this ).find( 'a' ).click()

      # Insert 'vs.' between the two comparate groups.
      $( '.nested-fields > .comparate-groups' )
        .find( '.nested-fields.comparates' )
        .first()
        .after( $( '<div style="text-align: center; font-weight: normal;">vs.</div>' ) )

      if $( '.wac-comparate-fields' ).length == 2
        $( '.wac-comparate-fields:eq(1)' ).find( 'select option' ).filter( ->
          return this.text.includes('Baseline')
        ).attr('selected', true)

      $( '.links.add-anova a' ).click()
      $( '.links.add-anova a' ).addClass( 'disabled' )

      $( '.links.add-comparison a' ).addClass( 'disabled' )

      bac_select = $( insertedItem ).find( '.bac-select' ).first()

      # When ANOVA is selected, hide the submit button for the comparison and replace with ANOVA form's submit button
      # We also hide all the second dropdown and Add comparate buttons
      bac_anova_handler = ( event ) ->
        if $( event.target ).find( 'option:selected' ).first().val() == "000"
          $( event.target ).closest( '.comparate-groups' ).children().hide()
          $( event.target ).closest( '.comparates' ).show()
          $( event.target ).closest( '.comparates' ).find( '.add-comparate' ).hide()

          $( '.submit-comparison' ).toggleClass( 'hide' )
          $( '.submit-anova' ).toggleClass( 'hide' )

        else
          $( event.target ).closest( '.comparate-groups' ).children().show()
          $( event.target ).closest( '.comparates' ).find( '.add-comparate' ).show()
          $( '.submit-comparison' ).toggleClass( 'hide' )
          $( '.submit-anova' ).toggleClass( 'hide' )

      if bac_select
        bac_select.find( 'option' )
          .first()
          .text( 'All Arms (ANOVA)' )
          .val( '000' )
        bac_select.change( bac_anova_handler )
        bac_select.trigger( 'change' )

######## coloring and consolidation dropdown

get_result_value = ( td_elem ) ->
  inputs = $( td_elem ).find( "input.string" )
  return ( if inputs.length > 0 then inputs[ 0 ].value else "" )

  get_result_elem = ( td_elem ) ->
    inputs = $( td_elem ).find( "input.string" )
    return ( if inputs.length > 0 then inputs[ 0 ] else null )

  get_result_number_of_extractions = ( ) ->
    questions = $( 'table.consolidated-data-table tbody' )
    if questions.length > 0
      rows = $( questions[ 0 ] ).find( 'tr' )
      return Math.max( 0, rows.length - 1 )
    return 0

  get_result_extractor_names = ( ) ->
    questions = $( 'table.consolidated-data-table tbody' )
    if questions.length > 0
      extractor_names = []
      $rows = $( questions[ 0 ] ).find( 'tr' )
      $rows.each ( tr_id, tr_elem ) ->
        $( tr_elem ).find( "td.extractor-name" ).each ( td_id, td_elem ) ->
          if td_id == 0
            extractor_names.push td_elem.innerHTML
      return extractor_names
    return []

  add_change_listeners_to_results_section = ( ) ->
    number_of_extractions = get_result_number_of_extractions( )

    $( 'table.consolidated-data-table tbody' ).each ( row_id, row_elem ) ->
      $( row_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
        $( tr_elem ).find( 'td' ).not( '.extractor-name' ).each ( td_id, td_elem ) ->
          if tr_id == number_of_extractions
            input_elem = get_result_elem( td_elem )
            if input_elem
              $( input_elem ).keyup ->
                result_section_coloring( )

  result_section_coloring = ( ) ->
    number_of_extractions = get_result_number_of_extractions( )

    $( 'table.consolidated-data-table tbody' ).each ( row_id, row_elem ) ->
      a_dict = { }
      $( row_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
        # hold the values for matching
        $( tr_elem ).find( 'td' ).not( '.extractor-name' ).each ( td_id, td_elem ) ->
          if tr_id < number_of_extractions
            a_dict[ "counts" ] ||= { }
            a_dict[ "counts" ][ td_elem.innerHTML ] ||= 0
            a_dict[ "counts" ][ td_elem.innerHTML ]++
          else
            a_dict[ "consolidated_value" ] = get_result_value( td_elem )
            a_dict[ "consolidated_elem" ] = td_elem

      color = "#E8DAEF"
      $.each a_dict[ "counts" ], ( value, count ) ->
        if count != number_of_extractions
          if a_dict[ "consolidated_value" ] != ""
            color = "#D1F2EB"
          else
            color = "#FADBD8"
        else
          if a_dict[ "consolidated_value" ] == value
            color = "#E8DAEF"
          else
            color = "#D1F2EB"

        $( a_dict[ "consolidated_elem" ] ).css( 'background', color )


  result_section_dropdowning = ( ) ->
    number_of_extractions = get_result_number_of_extractions( )
    extractor_names = get_result_extractor_names( )

    $( 'td.consolidated-data-cell' ).each ( cell_id, cell_elem ) ->
      a_dict = { }

      $drop_elem = $ "<select>"

      for extraction_id in [ 0..number_of_extractions ]
        drop_option = $ "<option>"
        drop_option.text extractor_names[ extraction_id ]
        drop_option.val extraction_id
        if extraction_id == number_of_extractions
          drop_option.prop( "selected", true )
        $drop_elem.append drop_option

      $( cell_elem ).find( 'table.consolidated-data-table tbody' ).each ( row_id, row_elem ) ->
        a_dict[ row_id ] ||= { }
        $( row_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
          $( tr_elem ).find( 'td' ).not( '.extractor-name' ).each ( td_id, td_elem ) ->
            if tr_id < number_of_extractions
              a_dict[ row_id ][ tr_id ] = td_elem.innerHTML
            else
              a_dict[ row_id ][ tr_id ] = get_result_value( td_elem )

      $drop_elem.change ( ) ->
        $( cell_elem ).find( 'table.consolidated-data-table tbody' ).each ( row_id, row_elem ) ->
          $( row_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
            $( tr_elem ).find( 'td' ).not( '.extractor-name' ).each ( td_id, td_elem ) ->
              if tr_id == number_of_extractions
                selected_id = $drop_elem.children("option").filter(":selected")[ 0 ].value
                input_elem = get_result_elem( td_elem )
                $( input_elem ).val( a_dict[ row_id ][ selected_id ] )
                result_section_coloring( )
                $( input_elem ).trigger( 'keyup' )

      $( cell_elem ).find( "div.consolidated-dropdown" ).html( $drop_elem )

  result_section_coloring()
  result_section_dropdowning()
  add_change_listeners_to_results_section()