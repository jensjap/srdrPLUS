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


   # $( '.consolidated-question' ).each ( cq_id, cq_elem ) ->
   #   $( cq_elem ).find( 'tbody tr' ).each ( tr_id, tr_elem ) ->
   #     # there is only one row with id 1
   #     $( tr_elem ).find( 'td' ). each ( td_id, td_elem ) ->
   #       console.log 'loyloy - ' + cq_id + ' - ' + tr_id + ' - ' + td_id


    get_question_value = ( question ) ->
      # this should cover both text and numeric
      str_input = $( question ).find( 'input.string[type!="hidden"]' )[0]
      if str_input
        return str_input.value

      # checkboxes
      cb_arr = []
      $( question ).find( 'input.check_boxes[checked="checked"]' ).each ( input_id, input_elem ) ->
        cb_arr.push input_elem.value
      if cb_arr.length > 0
        return cb_arr.join( "&&" )

      # dropdown
      drop_input = $( question ).find( 'select' )[0]
      if drop_input
        selected = $( drop_input ).children("option").filter(":selected")[0]
        if selected.value
          return selected.text
        else
          return ""

      # radio buttons
      a = $( question ).find( 'input.radio_buttons[checked="checked"]' )
      if a.length == 1
        return a[0].value

      return ""

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
                    a = get_question_value( td_elem )
                    #console.log "RETURNED: " + a
                    b_dict[arm_row_id][tr_id][td_id][get_question_value( td_elem )] ||= 0
                    b_dict[arm_row_id][tr_id][td_id][get_question_value( td_elem )]++
      
      console.log( b_dict )
      #$( '.consolidated-question' ).each ( cq_id, cq_elem ) ->

      $.each b_dict, ( arm_row_id, tr_dict ) ->
        #console.log ( "arm_row_id --> " + arm_row_id )
        color = ""
        $.each tr_dict, ( tr_id, td_dict ) ->
          #console.log ( "tr_id --> " + tr_id )
          $.each td_dict, ( td_id, value_dict ) ->
            #console.log ( "td_id --> " + td_id )
            $.each value_dict, ( value, value_count ) ->
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
          $( a_dict[ arm_row_id ] ).css( 'border-color', 'red' )
        else if color == "green"
          $( a_dict[ arm_row_id ] ).css( 'border-color', 'green' )

                  


