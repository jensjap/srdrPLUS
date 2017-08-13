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

    prereqOn = ( prereq ) ->
      _off = $( '.off-' + prereq )

      if _off.length
        _off.removeClass( 'off-' + prereq ).addClass( prereq )

#    findAndToggle = ( prereq ) ->
#      _on  = $( '.' + prereq )
#      _off = $( '.off-' + prereq )
#
#      if _on.length
#        prereqOff( prereq )
#
#      else if _off.length
#        prereqOn( prereq )
#
#      return

    $( '#preview .card input,select' ).keyup ( e ) ->
      e.preventDefault()
      that = $( this )
      prereq = that.data( 'prereq' )

      # Text.
      if that.is( 'input[type="text"]' ) && that[0].value
        prereqOff( prereq )

      else if that.is( 'input[type="text"]' ) && that[0].value == ''
        prereqOn( prereq )

      # Numeric, Numeric_Range, Scientific.
      else if that.is( 'input[type="number"]' ) && that[0].value
        prereqOff( prereq )

      else if that.is( 'input[type="number"]' ) && that[0].value == ''
        prereqOn( prereq )

      # Checkbox.
      # This is quite complicated. Not only do we need to ensure that we are correctly turning
      # dependencies on and off based on the checked status of this checkbox, we also need to check
      # if there are any dependencies that rely on this particular checkbox and also if there are
      # siblings that are checked or unchecked and have corresponding dependencies that may be
      # fulfilled still.
      else if that.is( 'input[type="checkbox"]' )

        # Ensure this checkbox is a dependency for something on this page before turning off all
        # of this and its siblings' dependencies.
        if that[0].checked && $( '.' + prereq ).length

          # Turn off prereq of this checkbox first.
          prereqOff( prereq )

          # Turn off prereq of siblings.
          that.siblings( 'input[type="checkbox"]' ).each ( index ) ->
            siblingPrereq = $( this ).data( 'prereq' )
            prereqOff( siblingPrereq )
            return

        # In this case we turn dependencies on, but we also need to check siblings and ensure they
        # don't fulfill dependencies.
        else

          # Ensure this checkbox is a dependency for something first.
          if $( '.off-' + prereq ).length

            # Since it is, we turn on dependency.
            prereqOn( prereq )

            # Now check siblings.
            that.siblings( 'input[type="checkbox"]' ).each ( index ) ->
              sibling = $( this )
              siblingPrereq1 = sibling.data( 'prereq' )

              # Ensure that checked sibling is a dependency before doing anything else.
              if sibling[0].checked && $( '.off-' + siblingPrereq1 ).length

                # Turn off prereq of siblings including the guy that triggered all this.
                sibling.siblings( 'input[type="checkbox"]' ).each ( index ) ->
                  nestedSibling = $( this )
                  siblingPrereq2 = nestedSibling.data( 'prereq' )
                  prereqOff( siblingPrereq2 )
                  return

              # Otherwise, turn the dependency on.
              else
                prereqOn( siblingPrereq1 )

              return

      # Dropdown, Select2_Single, Select2_Multi.
      else if that.is( 'select' )

        # Ensure this dropdown choice is a dependency for something first.
        selected = that.find( ':selected' )
        prereq = selected.data( 'prereq' )

        if $( '.' + prereq ).length || $( '.off-' + prereq ).length
          prereqOff( prereq )

          selected.siblings( 'option' ).each ( index ) ->
            siblingPrereq = $( this ).data( 'prereq' )
            prereqOff( siblingPrereq )
            return

        else
          prereqOn( prereq )

          $( this ).children( 'option' ).each ( index ) ->
            siblingPrereq = $( this ).data( 'prereq' )
            prereqOn( siblingPrereq )
            return

      # Radio.
      else if that.is( 'input[type="radio"]' )

        if $( '.' + prereq ).length || $( '.off-' + prereq ).length
          prereqOff( prereq )

          that.siblings( 'input[type="radio"]' ).each ( index ) ->
            siblingPrereq = $( this ).data( 'prereq' )
            prereqOff( siblingPrereq )
            return

        else
          prereqOn( prereq )

          that.siblings( 'input[type="radio"]' ).each ( index ) ->
            siblingPrereq = $( this ).data( 'prereq' )
            prereqOn( siblingPrereq )
            return

      return # $( '.card input,select' ).change ->

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
