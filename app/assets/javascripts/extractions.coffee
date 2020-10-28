# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  return unless $( '.extractions' ).length > 0

  do ->
    ## SELECT2 INITIALIZATION FOR EXTRACTION INDEX
    $( '.index-extractions-select2' ).select2()

    ## SELECT2 INITIALIZATION FOR NEW EXTRACTION
    $( '.new-extraction-select2' ).select2()
    $( '.new-extraction-select2-multi' ).select2( multiple: 'true', placeholder: '-- Select citation to be extracted --' )

    ## SELECT2 INITIALIZATION FOR CONSOLIDATION
    $( '.consolidation-select2' ).select2()
    $( '.consolidation-select2-multi' ).select2( multiple: 'true' )

    $( '.change-outcome-link' ).click ( e ) ->
      $( '#results-panel > .table-container' ).html( '<br><br><br><h1>loading..</h1>' )
      e.preventDefault()
      return

    $( '#results-panel .table-container' ).scroll ->
      # End of the document reached?
      if $( this ).prop( 'scrollHeight' ) - $( this ).height() == $( this ).scrollTop()
        console.log 'Scrolled to Bottom'
      return

    #################################################
    # State toggler for eefps
#    for status_name_elem in $( '.eefps-status-name' )
#      if $( status_name_elem ).val() == 'Completed'
#        eefps_id = $( status_name_elem ).attr( 'eefps-id' )
#        $( ".status-switch .switch-input[eefps-id=" + eefps_id + "]" ).prop( 'checked', true )
#        $( ".status-switch .switch-input[eefps-id=" + eefps_id + "]" ).change()

    if $( 'body.extractions.index, body.extractions.comparison_tool' ).length > 0
      #################################################
      # Editable ProjectsUserRole
      $( '.projects-users-role' ).hover(
        ->
          $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-select' ).removeClass( 'hide' )
          $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-label' ).addClass( 'hide' )
        ->
          if $( this ).closest( '.projects-users-role' ).attr( 'dropdown-active' ) == 'false'
            $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-select' ).addClass( 'hide' )
            $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-label' ).removeClass( 'hide' )
      )

      $( 'body' ).on 'click', ( event ) ->
        $( '.projects-users-role-select' ).each () ->
          if ( not $( event.target ).closest( '.projects-users-role-select' ).is( this ) ) and ( not $( event.target ).hasClass( 'projects-users-role-label' ))
            $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-select' ).addClass( 'hide' )
            $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-label' ).removeClass( 'hide' )
            $( this ).closest( '.projects-users-role' ).attr( 'dropdown-active', 'false' )

      $( '.projects-users-role' ).on 'click', ( event ) ->
        #$( this ).closest( '.projects-users-role' ).find( '.projects-users-role-select' ).removeClass( 'hide' )
        $( this ).closest( '.projects-users-role' ).attr( 'dropdown-active', 'true' )
        #$( this ).addClass( 'hide' )

      $( '.projects-users-role-select select' ).on 'change', ( event ) ->
        $( this ).closest( 'form' ).submit()
        $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-select' ).addClass( 'hide' )
        $( this ).closest( '.projects-users-role' ).find( '.projects-users-role-label' ).removeClass( 'hide' )
        $( this ).closest( '.projects-users-role' ).attr( 'dropdown-active', 'false' )

      # DataTables for Extractions List
      dt = $( 'table.extractions-list' ).DataTable({
             "info": false,
             "columnDefs": [{ "orderable": false, "targets": "_all" }]
           })
      dt.draw()

      last_col = 0
      $('table.extractions-list').on('click', '.table-sortable', (e) ->
        element = $(this)
        col = element.data('sorting-col')

        if (element.hasClass('sorting'))
          dt.order([col, 'asc']).draw();
          element.removeClass('sorting')
          element.addClass('sorting_asc')
        else if (element.hasClass('sorting_asc'))
          dt.order([col, 'desc']).draw();
          element.removeClass('sorting_asc')
          element.addClass('sorting_desc')
        else if (element.hasClass('sorting_desc'))
          dt.order([6, 'desc']).draw();
          element.removeClass('sorting_desc')
          element.addClass('sorting')
          $('[data-sorting-col=6]').removeClass('sorting_desc')
        if (last_col != col)
          $("[data-sorting-col=#{last_col}]").addClass('sorting')
        last_col = col
      )
      dt.order([6, 'desc']).draw();
      $('[data-sorting-col=6]').removeClass('sorting_desc')

      # DataTables for Comparisons List
      dtComparisonList = $( 'table.comparisons-list' ).DataTable({
             "paging": false,
             "info": false,
             "columnDefs": [{ "orderable": false, "targets": [3] }]
           })
      dtComparisonList.rows( { page:'current' } ).invalidate()
      dtComparisonList.draw()

    if $( 'body.extractions.work' ).length > 0
      #################################################
      # Attach listener to outcome population selector.
      $( '#outcome_populations_selector_eefpst1_id' ).change ( event ) ->
        $.ajax
          url: '/extractions_extraction_forms_projects_sections_type1s/' + this.value + '/get_results_populations'
          type: 'GET'
          dataType: 'script'
          error: -> alert 'Server busy. Please try again later.'
          timeout: 5000


    if $( 'body.extractions' ).length > 0
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

        #numeric
        if $( question ).find( 'input[type="number"]' ).length == 1
          return "numeric"

        # text
        if $( question ).find( 'textarea' ).length == 1
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
          when "text"
            return $( question ).find( 'textarea' )[ 0 ].value

          when "numeric"
            sign_option = $( $( question ).find( 'select' )[ 0 ] ).children('option').filter(':selected')[ 0 ]

            numeric_value = ""
            if sign_option
              numeric_value += sign_option.value || ""
            numeric_value += "&&&&&"
            numeric_value += $( question ).find( 'input[type="number"]' )[ 0 ].value || ""
            return numeric_value

          when "checkbox"
            cb_arr = []
            $( question ).find( 'input.check_boxes' ).filter( ':checked' ).each ( input_id, input_elem ) ->
              cb_arr.push input_elem.value
            return ( if cb_arr.length > 0 then cb_arr.join( "&&" ) else "" )


          when "dropdown"
            drop_input = $( question ).find( 'select' )[ 0 ]
            if drop_input
              val = $( drop_input ).val()
              return ( if val then val else "" )

          when "radio_buttons"
            rb_selected = $( question ).find( 'input.radio_buttons' ).filter(':checked')
            # there should ever be one
            return ( if rb_selected.length == 1 then rb_selected[ 0 ].value else "" )

          else
            return ""

      add_change_listeners_to_questions = (  ) ->
        number_of_extractions = get_number_of_extractions( )

        $( '.consolidation-data-row' ).each ( row_id, row_elem ) ->
          $( row_elem ).children( 'tr' ).each ( arm_row_id, arm_row_elem ) ->
            $( arm_row_elem ).find( 'td tbody' ).each ( cell_id, cell_elem ) ->
              $( cell_elem ).find( 'tr' ).each ( tr_id, tr_elem ) ->
                $( tr_elem ).find( 'td' ).each ( td_id, td_elem ) ->
                  if td_id != 0 && cell_id == number_of_extractions
                    switch get_question_type( td_elem )
                      when "text"
                        $( td_elem ).find( 'input.string' ).keyup ->
                          apply_coloring( )

                      when "numeric"
                        $( td_elem ).find( 'input.number' ).keyup ->
                          apply_coloring( )

                        $( td_elem ).find( 'select' ).change ->
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
                        switch c_dict[ arm_row_id ][ cell_id ][ tr_id ][ td_id ][ "question_type" ]
                          when "text"
                            $( td_elem ).find( 'textarea' ).val( new_value )
                            ## auto save expects keyup for textfield
                            $( td_elem ).find( 'textarea' ).trigger( 'keyup' )

                          when "numeric"
                            new_sign = new_value.split( "&&&&&" )[ 0 ]
                            new_val = new_value.split( "&&&&&" ).pop()

                            $( td_elem ).find( 'select' ).val( new_sign )
                            $( td_elem ).find( 'select' ).trigger( 'change' )

                            $( td_elem ).find( 'input[type="number"]' ).val( new_val )
                            $( td_elem ).find( 'input[type="number"]' ).trigger( 'keyup' )

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
            color_dict = { }
            value_arr = [ ]

            $.each tr_dict, ( tr_id, td_dict ) ->
              color_dict[ tr_id ] ||= { }
              $.each td_dict, ( td_id, value_dict ) ->
                color_dict[ tr_id ][ td_id ] = ""
                $.each value_dict, ( value, value_count ) ->
                  value_arr.push value
                  if ( value_count != number_of_extractions )
                    if consolidated_value[ tr_id ][ td_id ] != ""
                      color_dict[ tr_id ][ td_id ] = "#D1F2EB"
                    else
                      color_dict[ tr_id ][ td_id ] = "#FADBD8"
                  else
                    if value != consolidated_value[ tr_id ][ td_id ]
                      color_dict[ tr_id ][ td_id ] = "#D1F2EB"
                    #else
                      #color_dict[ tr_id ][ td_id ] = "#E8DAEF"

            $.each color_dict, ( tr_id, color_tr_dict ) ->
              $.each color_tr_dict, ( td_id, color ) ->
                if !!consolidated_cell[ tr_id ][ td_id ]
                  consolidated_cell[ tr_id ][ td_id ].css( 'background', color )

      ## call coloring for the first time
      add_change_listeners_to_questions( )
      apply_coloring( )
      apply_consolidation_dropdown( )

      $(".suggestedChoices").select2({
        tags: true
      });

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
