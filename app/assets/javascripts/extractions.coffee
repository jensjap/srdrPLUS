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
        str_input = $( str_input_arr[0] )
        if str_input.attr( "type" ) == "number"
          return "numeric"
        if str_input.attr( "type" ) == "text"
          return "text"

      #checkbox
      cb_input_arr = $( question ).find( 'div.input.check_boxes' )
      if str_input_arr.length > 0
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
          return $( question ).find( 'input.string' )[0].value

        when "checkbox"
          cb_arr = []
          $( question ).find( 'input.check_boxes[checked="checked"]' ).each ( input_id, input_elem ) ->
            cb_arr.push input_elem.value
          if cb_arr.length > 0
            return cb_arr.join( "&&" )

        when "dropdown"
          drop_input = $( question ).find( 'select' )[0]
          if drop_input
            selected = $( drop_input ).children("option").filter(":selected")[0]
            return ( if selected.value then selected.value else "" )

        when "radio_buttons"
          rb_selected = $( question ).find( 'input.radio_buttons[checked="checked"]' )
          # there should ever be one
          return ( if rb_selected.length == 1 then rb_selected[0].value else "" )

        else
          return ""
#      
#      # this should cover both text and numeric
#      str_input = $( question ).find( 'input.string[type!="hidden"]' )[0]
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
#      drop_input = $( question ).find( 'select' )[0]
#      if drop_input
#        selected = $( drop_input ).children("option").filter(":selected")[0]
#        if selected.value
#          return selected.text
#        else
#          return ""
#
#      # radio buttons
#      a = $( question ).find( 'input.radio_buttons[checked="checked"]' )
#      if a.length == 1
#        return a[0].value
#
#      return ""

    get_consolidation_dropdown = ( cell_elem, values_arr ) ->
      #there should only be one
      console.log cell_elem
      table_elem = $( cell_elem ).children( "table" )[0]

      dd_elem = $ "<select>"

      for value in values_arr
        dd_elem.append $( "<option>" ).text( value ).val( value )
      
      dd_elem.append $( "<option>" ).text( "Other" )
      dd_div = $( "<div>" )#.addClass "table-scroll clean-table"
      dd_div.append dd_elem

      dd_elem.change ->
        if dd_elem.find( ':selected' ).attr( "value" )

          table_elem.hide()
          console.log "ley"
        else
          table_elem.unhide()
          console.log "loy"

      return dd_div
    

    $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
      a_dict = { }
      b_dict = { }
      c_dict = { }

      number_of_extractions = 0

      #arm rows
      $arm_rows = $( row_elem ).children( 'tr' )
      $arm_rows.each ( arm_row_id, arm_row_elem ) ->
        c_dict[arm_row_id] ||= { }
        b_dict[arm_row_id] ||= { }
        $question_cells = $( arm_row_elem ).children( 'td' )
        number_of_extractions = $question_cells.length - 1
        $question_cells.each ( cell_id, cell_elem ) ->
          if cell_id == number_of_extractions
            a_dict[arm_row_id] = cell_elem
            $( cell_elem ).find( 'tbody' ).each ( idx, cell_body ) ->
              $( cell_body ).find( 'tr' ).each ( tr_id, tr_elem ) ->
                c_dict[arm_row_id][tr_id] ||= { }
                # there is only one row with id 1
                $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                  ## is there a better way to skip the header?
                  if td_id != 0
                    c_dict[arm_row_id][tr_id][td_id] = get_question_value( td_elem )
          if cell_id != number_of_extractions
            ## there should only be one
            $( cell_elem ).find( 'tbody' ).each ( idx, cell_body ) ->
              $( cell_body ).find( 'tr' ).each ( tr_id, tr_elem ) ->
                b_dict[arm_row_id][tr_id] ||= { }
                # there is only one row with id 1
                $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                  ## is there a better way to skip the header?
                  if td_id != 0
                    b_dict[arm_row_id][tr_id][td_id] ||= { }
                    question_value = get_question_value( td_elem )
                    b_dict[arm_row_id][tr_id][td_id][question_value] ||= 0
                    b_dict[arm_row_id][tr_id][td_id][question_value]++
      
      $.each b_dict, ( arm_row_id, tr_dict ) ->
        #console.log ( "arm_row_id --> " + arm_row_id )
        color = ""
        value_arr = []
        cell_elem = a_dict[ arm_row_id ]
        
        $.each tr_dict, ( tr_id, td_dict ) ->
          #console.log ( "tr_id --> " + tr_id )
          $.each td_dict, ( td_id, value_dict ) ->
            #console.log ( "td_id --> " + td_id )
            $.each value_dict, ( value, value_count ) ->
              value_arr.push value
              #console.log ( value + " --> " + value_count )
              if ( value_count != number_of_extractions )
                if c_dict[arm_row_id][tr_id][td_id] != ""
                  color = "green"
                else
                  color = "red"
              else if (value != c_dict[arm_row_id][tr_id][td_id])
                color = "green"

        # what happens if i change the consolidated answer by hand to be the same as the auto_consolidate answer,
        # how do i identify that
        if color == "red"
          $( cell_elem ).css( 'border-color', 'red' )
        else if color == "green"
          $( cell_elem ).css( 'border-color', 'green' )

        $( cell_elem ).prepend get_consolidation_dropdown( cell_elem, value_arr )
