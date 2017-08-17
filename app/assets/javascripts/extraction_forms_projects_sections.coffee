# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->

    ###############################################
    # Set the field to display from the result set.
    formatResultSelection = ( result, container ) ->
      result.text

    # Markup result.
    formatResult = ( result ) ->
      if result.loading
        return result.text
      markup = '<span>'
      if ~result.text.indexOf 'Pirate'
        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
      if ~result.text.indexOf 'New item: '
        #!!! Maybe add some styling.
        markup += ''
      markup += result.text
      if result.suggestion
        markup += ' (suggested by ' + result.suggestion.first_name + ')'
      markup += '</span>'
      markup

    # /extraction_forms_projects_sections/3/preview
    $( '#preview .question-row-column .select2' ).select2
      placeholder: '--Select--'
      minimumInputLength: 0
      ajax:
        url: ->
          id = $( this ).parent().data( 'question-row-column-id' )
          return '/question_row_columns/' + id + '/answer_choices'
        dataType: 'json'
        delay: 250
        data: ( params ) ->
          q: params.term
          page: params.page
        processResults: ( data, params ) ->
          # parse the results into the format expected by Select2
          # since we are using custom formatting functions we do not need to
          # alter the remote JSON data, except to indicate that infinite
          # scrolling can be used.
          # The server may respond with params.page, set it to 1 if not.
          params.page = params.page || 1;
          results: $.map( data.items, ( i ) ->
            id: i.id
            text: i.name
            suggestion: i.suggestion
          )
      escapeMarkup: ( markup ) ->
        markup
      templateResult: formatResult
      templateSelection: formatResultSelection

    # /extraction_forms_projects/1/extraction_forms_projects_sections/new
    $( '#extraction_forms_projects_section_section_id' ).select2
      placeholder: '--Select--'
      minimumInputLength: 0
      ajax:
        url: '/sections.json'
        dataType: 'json'
        delay: 250
        data: ( params ) ->
          q: params.term
          page: params.page
        processResults: ( data, params ) ->
          # parse the results into the format expected by Select2
          # since we are using custom formatting functions we do not need to
          # alter the remote JSON data, except to indicate that infinite
          # scrolling can be used.
          # The server may respond with params.page, set it to 1 if not.
          params.page = params.page || 1
          results: $.map( data.items, ( i ) ->
            id: i.id
            text: i.name
            suggestion: i.suggestion
          )
      escapeMarkup: ( markup ) ->
        markup
      templateResult: formatResult
      templateSelection: formatResultSelection


    ##############################################################################
    # Find and remove prereq- classes when input field has value in preview block.
    prereqOff = ( prereq ) ->
      _on  = $( '.' + prereq )

      if _on.length
        _on.removeClass( prereq ).addClass( 'off-' + prereq )
        _on.find( 'input' ).each ->
          $( this ).val( $( this ).data( 'previous-value' ) ).trigger( 'change' )
        _on.find( 'input[type="checkbox"]' ).each ->
          $( this ).prop( 'checked', $( this ).data( 'previous-value' ) ).trigger( 'change' )
        _on.find( 'select' ).each ->
          $( this ).val( $( this ).data( 'previous-value' ) ).trigger( 'change' )
        _on.find( 'input[type="radio"]' ).each ->
          $( this ).prop( 'checked', $( this ).data( 'previous-value' ) ).trigger( 'change' )

      return  # END prereqOff = ( prereq ) ->


    prereqOn = ( prereq ) ->
      _off = $( '.off-' + prereq )

      if _off.length
        _off.removeClass( 'off-' + prereq ).addClass( prereq )
        _off.find( 'input' ).each ->
          $( this ).val( '' ).trigger( 'change' )
        _off.find( 'input[type="checkbox"]' ).each ->
          $( this ).prop( 'checked', false ).trigger( 'change' )
        _off.find( 'select' ).each ->
          $( this ).val( '' ).trigger( 'change' )
        _off.find( 'input[type="radio"]' ).each ->
          $( this ).prop( 'checked', false ).trigger( 'change' )

      return  # END prereqOn = ( prereq ) ->


    subroutine = ( that ) ->
      # Find whether or not what triggered this is active or inactive,
      # meaning whether they have value or not.
      # For checkbox and radio we determine active based on :checked status.
      active = that.is( ':checked' )

      # Anything else we get the value to determine whether it's active.
      if not active && not that.is( 'input[type="checkbox"]' ) && not that.is( 'input[type="radio"]' )
        active = that.val()

      # Find the data-prereq value.
      prereq = that.data( 'prereq' )

      # For dropdown and select2 data-prereq value is on :selected.
      if not prereq
        # Small problem with multiselect dropdown. The order of :selected can change
        # so we need to check all.
        if $.isArray( active )
          that.find( ':selected' ).each ->
            temp = $( this ).data( 'prereq' )
            # If we find even one that is a prereq for someone we use it.
            if $( '.' + temp ).length || $( '.off-' + temp ).length
              prereq = temp
            return
        else
          prereq = that.find( ':selected' ).data( 'prereq' )

      return {
        active: active
        prereq: prereq
        }  # END subroutine = ( that ) ->


    turnPrereqOffSelfAndDescendants = ( prereq, that ) ->
      # Turn off dependencies on itself...
      prereqOff( prereq )
      # ...and those surrounding it but within the closest table.
      that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->
        prereq = $( this ).data( 'prereq' )
        prereqOff( prereq )
        return  # END that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->
      return  # END turnPrereqOffSelfAndDescendants = () ->

    ##########################################################
    # On keyup we want to save the current value of the input.
    $( '#preview .card input' ).on 'keyup', ( e ) ->
      e.preventDefault()
      that = $( this )

      currentValue = that.val()
      that.data( 'previous-value', currentValue )

      return  # END $( '#preview .card input' ).on 'change keyup', ( e ) ->

    #############################
    # Do the same for checkboxes.
    $( '#preview .card input[type="checkbox"]' ).on 'mouseup', ( e ) ->
      e.preventDefault()
      that = $( this )

      isChecked = that.prop( 'checked' )
      that.data( 'previous-value', !isChecked )

      return  # END $( '#preview .card input[type="checkbox"]' ).on 'mouseup', ( e ) ->

    ###########################
    # Do the same for Dropdown.
    # #!!! This doesnt quite work. The keyup and mouseup events trigger
    # before the actual change so we get the value too early.
    $( '#preview .card select' ).on 'change', ( e ) ->
      e.preventDefault()
      that = $( this )

      isSelected = that.val()
      that.data( 'previous-value', isSelected )

      return  # END $( '#preview .card select' ).on 'mouseup', ( e ) ->

    ########################
    # Do the same for Radio.
    # #!!! This doesnt quite work. The keyup and mouseup events trigger
    # before the actual change so we get the value too early.
    $( '#preview .card input[type="radio"]' ).on 'change', ( e ) ->
      e.preventDefault()
      that = $( this )
      that.data( 'previous-value', that.is( ':checked' ) )
      that.siblings( 'input[type="radio"]' ).each ->
        $( this ).data( 'previous-value', $( this ).is( ':checked' ) )

      return  # END $( 'preview .card input[type="radio"]' ).on 'mouseup', ( e ) ->

    ##########################################################################
    # Check whether dependencies are fulfilled and change classes accordingly.
    $( '#preview .card input,select' ).on 'change keyup', ( e ) ->
      e.preventDefault()

      that   = $( this )
      result = subroutine( that )
      active = result.active
      prereq = result.prereq

      # Test if this was a prereq somewhere...if it was we need to look around within the
      # table to find all the others, leave it alone otherwise.
      if active && $( '.' + prereq ).length
        turnPrereqOffSelfAndDescendants( prereq, that )

      else
        prereqOn( prereq )
        that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->
          prereq = $( this ).data( 'prereq' )
          prereqOn( prereq )
          return  # END that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->

        that.closest( 'table' ).find( 'input,select' ).each ( idx ) ->
          that   = $( this )
          result = subroutine( that )
          active = result.active
          prereq = result.prereq

          # Turn off dependencies if the field is active and it is someone's prereq.
          if active && $( '.' + prereq ).length
            turnPrereqOffSelfAndDescendants( prereq, that )

          return  # END that.closest( 'table' ).find( 'input,select' ).each ( idx ) ->

      return  # END $( '#preview .card input,select' ).on 'change keyup', ( e ) ->

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
