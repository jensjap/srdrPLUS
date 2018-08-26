# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

#    # Adds a delay to calling a specific function.
#    delay = do ->
#      timer = 0
#      ( callback, ms ) ->
#        clearTimeout timer
#        timer = setTimeout( callback, ms )

    $( '#outcome_populations_selector_eefpst1_id' ).change ( event ) ->
      $.ajax
        url: '/extractions_extraction_forms_projects_sections_type1s/' + this.value + '/get_results_populations'
        type: 'GET'
        dataType: 'script'
        error: -> alert 'Server busy'
        timeout: 5000

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

      urlString = urlString.concat '&eefps_id='
      urlString = urlString.concat $this.data( 'eefps-id' )

      $( $this.data( 'extraction-ids' ) ).each ( idx, elem ) ->
        urlString = urlString.concat '&extraction_ids[]='
        urlString = urlString.concat elem

      $.ajax( urlString ).done ( resp ) ->
        $modal.html( resp ).foundation 'open'

    #############################################################
    # Attach listener to toggle section links in and out of view.
    $( '#toggle-sections-link' ).click ( e ) ->
      e.preventDefault
      $( '#toggle-sections-link .toggle-hide' ).toggleClass( 'hide' )
      $( '.toggle-sections-link-medium-2-0-hide' ).toggleClass( 'medium-2 medium-0 hide' )
      $( '.toggle-sections-link-medium-10-12' ).toggleClass( 'medium-10 medium-12' )

    # Attach listener to toggle the consolidated extraction_form in and out of view.
    $( '#toggle-consolidated-extraction-link' ).click ( e ) ->
      e.preventDefault
      $( '#toggle-consolidated-extraction-link .toggle-hide' ).toggleClass( 'hide' )
      $( '.toggle-consolidated-extraction-link-medium-8-12' ).toggleClass( 'medium-8 medium-12' )
      $( '.toggle-consolidated-extraction-link-medium-4-0-hide' ).toggleClass( 'medium-4 medium-0 hide' )


    get_number_of_extractions = () ->
      $questions = $( '.consolidation-data-row' )
      if $questions.length > 0
        $rows = $questions.children( 'tr' )
        return ( if $rows.length > 0 then Math.max( 0, $rows.first().children( 'td' ).length - 1 ) else 0 )

    get_extractor_names = () ->
      $panels = $( 'div[id^="panel-tab-"]' )
      if $panels.length > 0
        extractor_names = []
        $panels.first().find( 'th[extractor-name]' ).each ( extractor_id, extractor_elem ) ->
          extractor_names.push $( extractor_elem ).attr( 'extractor-name' )
        return extractor_names
      return []

    get_question_type = ( question ) ->
      ## We assume a question only ever has one type of input, 
      ## which may be a problem if I accidentally place the dropdown in the wrong place

      #text or numeric
      str_input_arr = $( question ).find( 'input.string' )
      if str_input_arr.length == 1
        str_input = $( str_input_arr[ 0 ] )
        if str_input.attr( "type" ) == "number"
          return "numeric"
        if str_input.attr( "type" ) == "text"
          return "text"

      #checkbox
      cb_input_arr = $( question ).find( 'div.input.check_boxes' )
      if cb_input_arr.length > 0
        return "checkbox"

      #dropdown
      drop_input_arr = $( question ).find( 'select' )
      if drop_input_arr.length > 0
        return "dropdown"

      #radio buttons
      rb_input_arr = $( question ).find( 'div.input.radio_buttons' )
      if rb_input_arr.length > 0
        return "radio_buttons"
        
      return "unclear"

    get_question_value = ( question ) ->
      switch get_question_type question
        when "text", "numeric"
          return $( question ).find( 'input.string' )[ 0 ].value

        when "checkbox"
          cb_arr = []
          $( question ).find( 'input.check_boxes[checked="checked"]' ).each ( input_id, input_elem ) ->
            cb_arr.push input_elem.value
           return ( if cb_arr.length > 0 then cb_arr.join( "&&" ) else "" )


        when "dropdown"
          drop_input = $( question ).find( 'select' )[ 0 ]
          if drop_input
            selected = $( drop_input ).children('option').filter(':selected')[ 0 ]
            return ( if selected.value then selected.value else "" )

        when "radio_buttons"
          rb_selected = $( question ).find( 'input.radio_buttons' ).filter(':checked')
          # there should ever be one
          return ( if rb_selected.length == 1 then rb_selected[ 0 ].value else "" )

        else
          return ""

    add_change_listeners_to_questions = (  ) ->
      number_of_extractions = get_number_of_extractions( )
      console.log number_of_extractions

      $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
        $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
          $( arm_row_elem ).find( 'td tbody' ).each ( cell_id, cell_elem ) ->
            $( cell_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
              $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                if td_id != 0 && cell_id == number_of_extractions
                  switch get_question_type( td_elem )
                    when "text", "numeric"
                      $( td_elem ).find( 'input.string' ).keyup ->
                        apply_coloring( )

                    when "checkbox"
                      $( td_elem ).find( 'input.check_boxes' ).each ( input_id, input_elem ) ->
                        $( input_elem ).change ->
                          apply_coloring( )

                    when "dropdown"
                      select_elem = $( td_elem ).find( 'select' )
                      $( select_elem ).change ->
                        apply_coloring( )

                    when "radio_buttons"
                      $( td_elem ).find( 'input.radio_buttons' ).each ( rb_index, rb_input ) ->
                        $( rb_input ).change ->
                          apply_coloring( )
                    else

    apply_consolidation_dropdown = ( ) ->
      number_of_extractions = get_number_of_extractions( )
      extractor_names = get_extractor_names( )

      $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
        # consolidated data values and cell_elem
        c_dict = { }

        $drop_elem = $ "<select>"

        for extraction_id in [ 0..number_of_extractions ]
          drop_option = $ "<option>"
          drop_option.text extractor_names[ extraction_id ]
          drop_option.val extraction_id
          if extraction_id == number_of_extractions
            drop_option.prop( "selected", true )
          $drop_elem.append drop_option

        $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
          c_dict[ arm_row_id ] ||= { }
          $( arm_row_elem ).find( 'td tbody' ).each ( cell_id, cell_elem ) ->
            c_dict[ arm_row_id ][ cell_id ] ||= { }
            $( cell_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
              c_dict[ arm_row_id ][ cell_id ][ tr_id ] ||= { }
              $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                if td_id != 0
                  c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ] ||= { }
                  c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_type" ] = get_question_type( td_elem )
                  c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_value" ] = get_question_value( td_elem )

        $drop_elem.change ->
          $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
            $( arm_row_elem ).find( 'td tbody' ).each ( cell_id, cell_elem ) ->
              if cell_id == number_of_extractions
                $( cell_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
                  $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                    ## is there a better way to skip the header?
                    if td_id != 0
                      cell_id = $drop_elem.children("option").filter(":selected")[ 0 ].value
                      new_value = c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_value" ]
                      #console.log "new_value: " + new_value
                      switch c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_type" ]
                        when "text", "numeric"
                          $( td_elem ).find( 'input.string' ).val( new_value )
                          ## auto save expects keyup for textfield
                          $( td_elem ).find( 'input.string' ).trigger( 'keyup' )

                        when "checkbox"
                          cb_arr = if new_value.length > 0 then new_value.split( "&&" ) else []
                          $( td_elem ).find( 'input.check_boxes' ).each ( input_id, input_elem ) ->
                            if input_elem.value in cb_arr
                              $( input_elem ).prop( 'checked', true )
                            else
                              $( input_elem ).prop( 'checked', false )
                            $( input_elem ).trigger( 'change' )

                        when "dropdown"
                          select_elem = $( td_elem ).find( 'select' )
                          $( select_elem ).val( new_value )
                          $( select_elem ).trigger( 'change' )

                        when "radio_buttons"
                          $( td_elem ).find( 'input.radio_buttons' ).each ( rb_index, rb_input ) ->
                            
                            if ( rb_input.value == new_value )
                              $( rb_input ).prop( 'checked', true )
                              
                            else
                              $( rb_input ).prop( 'checked', false )

                            $( rb_input ).trigger( 'change' )
                        else
              apply_coloring( )
      
        $( row_elem ).find( 'div#consolidation-dropdown' ).html( $drop_elem )

    apply_coloring = ( ) ->
      number_of_extractions = get_number_of_extractions( )
      extractor_arr = get_extractor_names( )

      $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
        # data matching tree
        b_dict = { }
        consolidated_cell = { }
        consolidated_value = { }

        $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
          b_dict[ arm_row_id ] ||= { }
          
          $( arm_row_elem ).find( 'td tbody' ).each ( cell_id, cell_elem ) ->
            $( cell_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
              b_dict[ arm_row_id ][ tr_id ] ||= { }
              consolidated_cell[ tr_id ] ||= { }
              consolidated_value[ tr_id ] ||= { }
              $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                ## is there a better way to skip the header?
                if td_id != 0
                  # if we are at an extraction's cell, populate the data matching tree
                  if cell_id != number_of_extractions
                    question_value = get_question_value( td_elem )
                    b_dict[ arm_row_id ][ tr_id ][ td_id ] ||= { }
                    b_dict[ arm_row_id ][ tr_id ][ td_id ][ question_value ] ||= 0
                    b_dict[ arm_row_id ][ tr_id ][ td_id ][ question_value ]++
                  else
                    consolidated_cell[ tr_id ][ td_id ] = $( td_elem )
                    consolidated_value[ tr_id ][ td_id ] = get_question_value( td_elem )

        $.each b_dict, ( arm_row_id, tr_dict ) ->
          #console.log ( "arm_row_id --> " + arm_row_id )
          color_dict = { }
          value_arr = [ ]
          
          $.each tr_dict, ( tr_id, td_dict ) ->
            #console.log ( "tr_id --> " + tr_id )
            color_dict[ tr_id ] ||= { }
            $.each td_dict, ( td_id, value_dict ) ->
              color_dict[ tr_id ][ td_id ] = ""
              #console.log ( "td_id --> " + td_id )
              $.each value_dict, ( value, value_count ) ->
                value_arr.push value
                #console.log ( value + " --> " + value_count )
               #console.log "consolidated value: " + c_dict[ arm_row_id ][ number_of_extractions ][ tr_id ][ td_id ][ "question_value" ]
                if ( value_count != number_of_extractions )
                  if consolidated_value[ tr_id ][ td_id ] != ""
                    color_dict[ tr_id ][ td_id ] = "green"
                  else
                    color_dict[ tr_id ][ td_id ] = "red"
                else
                  if value != consolidated_value[ tr_id ][ td_id ]
                    color_dict[ tr_id ][ td_id ] = "green"
                  else
                    color_dict[ tr_id ][ td_id ] = "#410093"
              
          $.each color_dict, ( tr_id, color_tr_dict ) ->
            $.each color_tr_dict, ( td_id, color ) ->
              consolidated_cell[ tr_id ][ td_id ].css( 'border', 'solid' )
              consolidated_cell[ tr_id ][ td_id ].css( 'border-color', color )

            
    ## call coloring for the first time
    add_change_listeners_to_questions( )
    apply_coloring( )
    apply_consolidation_dropdown( )

############### results section

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
              a_dict[ "consolidated_elem" ] = get_result_elem( td_elem )

        console.log a_dict

        color = "#410093"
        $.each a_dict[ "counts" ], ( value, count ) ->
          console.log count
          if count != number_of_extractions
            if a_dict[ "consolidated_value" ] != ""
              color = "green"
            else
              color = "red"
          else
            if a_dict[ "consolidated_value" ] == value
              color = "#410093"
            else
              color = "green"
        
          $( a_dict[ "consolidated_elem" ] ).css( 'border', 'solid' )
          $( a_dict[ "consolidated_elem" ] ).css( 'border-color', color )
    

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
                  $( input_elem ).trigger( 'keyup' )
                  result_section_coloring

        $( cell_elem ).find( "div.consolidated-dropdown" ).html( $drop_elem )

    add_change_listeners_to_results_section()
    result_section_coloring()
    result_section_dropdowning()
