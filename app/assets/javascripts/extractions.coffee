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
            selected = $( drop_input ).children("option").filter(":selected")[ 0 ]
            return ( if selected.value then selected.value else "" )

        when "radio_buttons"
          rb_selected = $( question ).find( 'input.radio_buttons[checked="checked"]' )
          # there should ever be one
          return ( if rb_selected.length == 1 then rb_selected[ 0 ].value else "" )

        else
          return ""
#      
#      # this should cover both text and numeric
#      str_input = $( question ).find( 'input.string[type!="hidden"]' )[ 0 ]
#      if str_input
#        return str_input.value
#
#      # checkboxes
#      cb_arr = []
#      $( question ).find( 'input.check_boxes[checked="checked"]' ).each ( input_id, input_elem ) ->
#        cb_arr.push input_elem.value
#      if cb_arr.length > 0
#        return cb_arr.join( "&&" )
#
#      # dropdown -- this can cause problems since I'm adding dropdowns to each consolidated question div
#      drop_input = $( question ).find( 'select' )[ 0 ]
#      if drop_input
#        selected = $( drop_input ).children("option").filter(":selected")[ 0 ]
#        if selected.value
#          return selected.text
#        else
#          return ""
#
#      # radio buttons
#      a = $( question ).find( 'input.radio_buttons[checked="checked"]' )
#      if a.length == 1
#        return a[ 0 ].value
#
#      return ""

    # what i need is a dictionary of cell_elements, since I know the last one is the consolidated one and the others are the extractions
    get_consolidation_dropdown = ( cell_dict, number_of_extractions ) ->
      consolidated_cell = cell_dict[ "cell_elem" ]
      drop_elem = $ "<select>"

      $.each cell_dict, ( cell_id, tr_dict ) ->
      for cell_id in [ 0..number_of_extractions ]
        #if cell_id != number_of_extractions
        tr_dict = cell_dict[ cell_id ]
        drop_option = $( "<option>" )
        drop_option.val( cell_id )
        drop_option.text( tr_dict[ "extractor" ] )
        if cell_id == number_of_extractions
          drop_option.prop( "selected", true )
        drop_elem.append drop_option

      drop_elem.change ->
        $( consolidated_cell ).find( 'tbody' ).each ( idx, cell_body ) ->
          $( cell_body ).find( 'tr' ).each ( tr_id, tr_elem ) ->
            $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
              ## is there a better way to skip the header?
              if td_id != 0
                cell_id = $( drop_elem ).children("option").filter(":selected")[ 0 ].value
                new_value = cell_dict[ cell_id ][ tr_id ][ td_id ][ "question_value" ]
                #console.log "new_value: " + new_value
                switch cell_dict[ cell_id ][ tr_id ][ td_id ][ "question_type" ]
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
                    drop_input = $( select_elem ).val( new_value )
                    $( select_elem ).trigger( 'change' )

                  when "radio_buttons"
                    $( td_elem ).find( 'input.radio_buttons' ).each ( rb_index, rb_input ) ->
                      #console.log "current val: " + rb_input.value
                      #console.log "equals to new_val:" + (rb_input.value == new_value )
                      
                      if ( rb_input.value == new_value )
                        $( rb_input ).prop( 'checked', true )
                        
                      else
                        $( rb_input ).prop( 'checked', false )

                      $( rb_input ).trigger( 'change' )
                  else
        apply_coloring()

      drop_div = $( "<div>" )#.addClass "table-scroll clean-table"
      drop_div.append drop_elem

#      drop_elem.change ->
#        if drop_elem.find( ':selected' ).attr( "value" )
#
#          consolidated_cell.hide()
#          console.log "ley"
#        else
#          consolidated_cell.show()
#          console.log "loy"

      return drop_div
    

    apply_coloring = ( ) ->
      $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
        # data matching tree
        b_dict = { }
        # consolidated data values and cell_elem
        c_dict = { }
        # holds all cell_elems
        a_dict = { }

        # extractor names
        extractor_arr = []
        #console.log  $( 'div[id^="panel-tab-"]' ).first()
        $( 'div[id^="panel-tab-"]' ).first().find( 'th[extractor-name]' ).each ( extractor_id, extractor_elem ) ->
          extractor_arr.push $( extractor_elem ).attr( 'extractor-name' )

        #console.log extractor_arr

        number_of_extractions = 0
        $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
          number_of_extractions = $( arm_row_elem ).children( 'td' ).length - 1
        console.log "#extractions = " + number_of_extractions

        #arm rows
        $arm_rows = $( row_elem ).children( 'tr' )
        $arm_rows.each ( arm_row_id, arm_row_elem ) ->
          a_dict[ arm_row_id ] ||= { }
          c_dict[ arm_row_id ] ||= { }
          b_dict[ arm_row_id ] ||= { }
          $question_cells = $( arm_row_elem ).children( 'td' )
          
          # not sure about this, we should be doing this only once
          # number_of_extractions = $question_cells.length - 1

          $question_cells.each ( cell_id, cell_elem ) ->
            # store cell_elem for dropdown
            a_dict[ arm_row_id ][ cell_id ] = cell_elem

            # if we are at the consolidated cell, store cell_elem
            if cell_id == number_of_extractions
              c_dict[ arm_row_id ][ "cell_elem" ] = cell_elem
            
            ## there should only be one
            $( cell_elem ).find( 'tbody' ).each ( idx, cell_body ) ->
              c_dict[ arm_row_id ][ cell_id ] ||= { }
              c_dict[ arm_row_id ][ cell_id ][ "extractor" ] = extractor_arr[ cell_id ]
              $( cell_body ).find( 'tr' ).each ( tr_id, tr_elem ) ->
                b_dict[ arm_row_id ][ tr_id ] ||= { }
                c_dict[ arm_row_id ][ cell_id ][ tr_id ] ||= { }
                # there is only one row with id 1
                $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                  ## is there a better way to skip the header?
                  if td_id != 0
                    # if we are at an extraction's cell, populate the data matching tree
                    if cell_id != number_of_extractions
                      question_value = get_question_value( td_elem )
                      b_dict[ arm_row_id ][ tr_id ][ td_id ] ||= { }
                      b_dict[ arm_row_id ][ tr_id ][ td_id ][ question_value ] ||= 0
                      b_dict[ arm_row_id ][ tr_id ][ td_id ][ question_value]++

                    c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ] ||= { }
                    c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_type" ] = get_question_type( td_elem )
                    c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_value" ] = get_question_value( td_elem )

        console.log b_dict
        
        $.each b_dict, ( arm_row_id, tr_dict ) ->
          #console.log ( "arm_row_id --> " + arm_row_id )
          color = ""
          value_arr = []
          cell_elem = c_dict[ arm_row_id ][ "cell_elem" ]
          
          $.each tr_dict, ( tr_id, td_dict ) ->
            #console.log ( "tr_id --> " + tr_id )
            $.each td_dict, ( td_id, value_dict ) ->
              #console.log ( "td_id --> " + td_id )
              $.each value_dict, ( value, value_count ) ->
                value_arr.push value
                console.log ( value + " --> " + value_count )
                console.log "consolidated value: " + c_dict[ arm_row_id ][ number_of_extractions ][ tr_id ][ td_id ][ "question_value" ]
                if ( value_count != number_of_extractions )
                  if c_dict[ arm_row_id ][ number_of_extractions ][ tr_id ][ td_id ][ "question_value" ] != ""
                    color = "green"
                  else
                    color = "red"
                else if ( value != c_dict[ arm_row_id ][ number_of_extractions ][ tr_id ][ td_id ][ "question_value" ] )
                  color = "green"

          # what happens if i change the consolidated answer by hand to be the same as the auto_consolidate answer,
          # how do i identify that
          if color == "red"
            $( cell_elem ).css( 'border-color', 'red' )
          else if color == "green"
            $( cell_elem ).css( 'border-color', 'green' )

          $( cell_elem ).find( 'div#consolidation-dropdown' ).html( get_consolidation_dropdown( c_dict[ arm_row_id ], number_of_extractions ) )

    ## call coloring for the first time
    apply_coloring()
