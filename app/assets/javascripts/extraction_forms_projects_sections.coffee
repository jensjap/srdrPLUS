# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->


  do ->
    if $( '.extraction_forms_projects.build, .extraction_forms_projects_sections, .extractions' ).length > 0
      ## ATTACH FOLLOWUPS
      $( '.attach-me' ).each () ->
        tether = new Tether({
          element: this,
          target: "label[for='" + ( $( "[data-attach-source='" + this.getAttribute('data-attach-target') + "']" )[0].id ) + "']",
          attachment: "center left",
          targetAttachment: "center right",
          offset: '-9px -10px'
        })
        tether.position();
      $( '.attach-me' ).removeClass('hide')

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
        placeholder: '-- Select or type other value --'
        width: '100%'
        minimumInputLength: 0
        ajax:
          url: ->
            id = $( this ).closest( '.question-row-column' ).data( 'question-row-column-id' )
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
        placeholder: '-- Select or type other value --'
        width: '100%'
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
  #        _on.find( 'input[type!="hidden"]' ).each ->
  #          $( this ).val( $( this ).data( 'previous-value' ) ).trigger( 'change' )
  #        _on.find( 'input[type="checkbox"]' ).each ->
  #          $( this ).prop( 'checked', $( this ).data( 'previous-value' ) ).trigger( 'change' )
  #        _on.find( 'select' ).not( '.select2' ).each ->
  #          $( this ).val( $( this ).data( 'previous-value' ) ).trigger( 'change' )
  #        _on.find( 'select.select2' ).each ->
  #          if $( this ).data( 'previous-value' )
  #            $( this ).val( $( this ).data( 'previous-value' ) ).trigger( 'change' )
  #        _on.find( 'input[type="radio"]' ).each ->
  #          $( this ).prop( 'checked', $( this ).data( 'previous-value' ) ).trigger( 'change' )

        return  # END prereqOff = ( prereq ) ->


      prereqOn = ( prereq ) ->
        _off = $( '.off-' + prereq )

        if _off.length
          _off.removeClass( 'off-' + prereq ).addClass( prereq )
  #        _off.find( 'input' ).each ->
  #          $( this ).val( '' ).trigger( 'change' )
  #        _off.find( 'input[type="checkbox"]' ).each ->
  #          $( this ).prop( 'checked', false ).trigger( 'change' )
  #        _off.find( 'select' ).each ->
  #          $( this ).val( null ).trigger( 'change' )
  #        _off.find( 'input[type="radio"]' ).each ->
  #          $( this ).prop( 'checked', false ).trigger( 'change' )

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
        # Turn off dependencies on itself..
        prereqOff( prereq )
        # ..and those surrounding it but within the closest table.
        that.closest( 'table' ).find( 'textarea[data-prereq],input[data-prereq],option[data-prereq]' ).each ( idx ) ->
          #prereq = $( this ).data( 'prereq' )
          prereqOff( prereq )
          return  # END that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->
        return  # END turnPrereqOffSelfAndDescendants = ( prereq, that ) ->

      turnPrereqOnSelfAndDescendants = ( prereq, that ) ->
        # Turn on dependencies on itself...
        prereqOn( prereq )
        # ..and those surrounding it but within the closest table.
        that.closest( 'table' ).find( 'textarea[data-prereq],input[data-prereq],option[data-prereq]' ).each ( idx ) ->
          prereq = $( this ).data( 'prereq' )
          prereqOn( prereq )
          return  # END that.closest( 'table' ).find( 'input[data-prereq],option[data-prereq]' ).each ( idx ) ->
        return  # END turnPrereqOnSelfAndDescendants = ( prereq, that ) ->

      ##############################################################
      # Save the value of the current input for each question field.
      # Text.
      $( '#preview .card input[type="text"]' ).on 'input', ( e ) ->
        e.preventDefault()

        that = $( this )
        currentValue = that.val()
        that.data( 'previous-value', currentValue )
        return  # END $( '#preview .card input[type="text"]' ).on 'input', ( e ) ->

      # Numeric.
      $( '#preview .card input[type="number"]' ).on 'input', ( e ) ->
        e.preventDefault()

        that = $( this )
        currentValue = that.val()
        that.data( 'previous-value', currentValue )
        return  # END $( '#preview .card input[type="number"]' ).on 'input', ( e ) ->

      # Checkbox.
      $( '#preview .card input[type="checkbox"]' ).on 'mouseup', ( e ) ->
        e.preventDefault()

        that = $( this )

        isChecked = that.prop( 'checked' )
        that.data( 'previous-value', !isChecked )
        return  # END $( '#preview .card input[type="checkbox"]' ).on 'mouseup', ( e ) ->

      # Dropdown.
      # The keyup and mouseup events trigger before the actual change
      # so we get the value too early. 'blur' to the rescue!
      $( '#preview .card select' ).on 'blur', ( e ) ->
        e.preventDefault()

        that = $( this )
        isSelected = that.val()
        that.data( 'previous-value', isSelected )
        return  # END $( '#preview .card select' ).on 'blur', ( e ) ->

      # Do the same for Select2.
      #!!! Multi select value of '' means that the '--select--' is chosen. This
      # creates problems when trying to restore the value.
      $( '#preview .card select.select2' ).on 'select2:close', ( e ) ->
        that = $( this )
        isSelected = that.val()
        that.data( 'previous-value', isSelected )
        return  # END $( '#preview .card select.select2' ).on 'select2:close', ( e ) ->

      # Radio.
      # The keyup and mouseup events trigger before the actual change
      # so we get the value too early. 'blur' to the rescue!
      $( '#preview .card input[type="radio"]' ).on 'blur', ( e ) ->
        e.preventDefault()

        that = $( this )
        that.data( 'previous-value', that.is( ':checked' ) )
        that.siblings( 'input[type="radio"]' ).each ->
          $( this ).data( 'previous-value', $( this ).is( ':checked' ) )
        return  # END $( 'preview .card input[type="radio"]' ).on 'blur', ( e ) ->

      ##########################################################################
      # Check whether dependencies are fulfilled and change classes accordingly.
      $( '#preview .card input, #preview .card select, #preview .card textarea' ).on 'change keyup', ( e ) ->
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
          noneActiveAndPrereq = true
          that.closest( 'table' ).find( 'input,select,textarea' ).each ( idx ) ->
            that   = $( this )
            result = subroutine( that )
            active = result.active
            prereq = result.prereq

            # Turn off dependencies if the field is active and it is someone's prereq.
            if active && $( '.off-' + prereq ).length
              noneActiveAndPrereq = false
              return false

            return  # END that.closest( 'table' ).find( 'input,select' ).each ( idx ) ->

          if noneActiveAndPrereq
            turnPrereqOnSelfAndDescendants( prereq, that )

        return  # END $( '#preview .card input,select' ).on 'change keyup', ( e ) ->

      updateCards = () ->
        # Hide all questions first.
        $( '.card' ).addClass( 'hide' )

        # Go over each key question checkbox and reveal question if its key question
        # prerequisite is checked.
        $( '.kqp-selector' ).each ->
          that = $( this )
          isChecked = that.prop( 'checked' )
          if isChecked
            kqId = that.attr( 'data-kqp-selection-id' )
            $( '.card.kqreq-'+kqId ).removeClass( 'hide' )

      $( 'input' ).trigger( 'change' )

      #################################################################################
      # Make all cards visible that require at least one of the key questions selected.
      $( '.key-question-selector input[type="checkbox"]' ).on 'change', ( e ) ->
        e.preventDefault()
        updateCards()
        $('#extractions-key-questions-projects-selections-form').submit()

      $(document).ready ->
        updateCards()

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
