document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  if $( 'body.public_data.show, .extraction_forms_projects.build, .extraction_forms_projects_sections, .extractions' ).length > 0
    #######################################################
    # ATTACH FOLLOWUPS
    #######################################################
    $('.attach-me').each () ->
      tether = new Tether({
        element: this,
        target: "label[for='" + ( $( "[data-attach-source='" + this.getAttribute('data-attach-target') + "']" )[0].id ) + "']",
        attachment: "center left",
        targetAttachment: "center right",
        offset: '-1px -10px'
      })
      setTimeout ( ->
        tether.position()
      ), 50
      return true
    $('.attach-me').removeClass('hide')

    #######################################################
    # SELECT2
    # Set the field to display from the result set.
    #######################################################
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

    #######################################################
    # Async Saving
    # Save the value of the current input for each question field.
    #######################################################
    # Text
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


    #######################################################
    # HIDING IRRELEVANT QUESTIONS
    #######################################################
    updateCards = () ->
      return if $( 'body.public_data.show' ).length > 0
      # Hide all questions first.
      $( '.card' ).addClass( 'hide' )

      # Go over each key question checkbox and reveal question if its key question
      # prerequisite is checked.
      $( '.kqp-selector' ).each ->
        that = $(this)
        isChecked = $(this).prop('checked')
        kqId = $(this).attr('data-kqp-selection-id')

        $("[data-kqp-selection-id=#{kqId}]").each ->
          if $(this) != that
            $(this).prop('checked', isChecked);

        if isChecked
          $( '.card.kqreq-'+kqId ).removeClass( 'hide' )

    $( 'input' ).trigger( 'change' )

    # Make all cards visible that require at least one of the key questions selected.
    $( '.key-question-selector input[type="checkbox"]' ).on 'change', ( e ) ->
      e.preventDefault()
      updateCards()
      $('#extractions-key-questions-projects-selections-form').submit()

    $(document).ready ->
      updateCards()


    #######################################################
    # PREREQS
    # Disable elements that don't have their prereq's met
    #######################################################

    findActivePrereq = (that) ->
      prereq = that.data('prereq')

      if that.is('input[type="checkbox"]') || that.is('input[type="radio"]')
        active = that.is(':checked')
      else if that.is('option')
        active = that.is(':selected')
      else
        active = !!that.val()

      # For dropdown and select2 data-prereq value is on :selected.
      if not prereq
        # Small problem with multiselect dropdown. The order of :selected can change
        # so we need to check all.
        if $.isArray(active)
          that.find(':selected').each ->
            temp = $(this).data('prereq')
            # If we find even one that is a prereq for someone we use it.
            if $('.' + temp).length || $('.off-' + temp).length
              prereq = temp
        else
          prereq = that.find(':selected').data('prereq')

      return { active, prereq }

    # Check whether dependencies are fulfilled and change classes accordingly.
    relevantIDsClasses = '#preview .card input, #preview .card select, #preview .card textarea'

    $(relevantIDsClasses).on 'change keyup dependencies:update', (e) ->
      e.preventDefault()
      e.stopPropagation()

      preReqLookup = {}
      $("input[data-prereq],option[data-prereq]").each (idx, element) ->
        { active, prereq } = findActivePrereq($(element))

        if preReqLookup[prereq] == undefined
          preReqLookup[prereq] = active
        else if active && preReqLookup[prereq] == false
          preReqLookup[prereq] = active

        return true

      Object.keys(preReqLookup).forEach (prereq) ->
        if preReqLookup[prereq]
          $('.' + prereq).removeClass(prereq).addClass('off-' + prereq)
        else
          $('.off-' + prereq).removeClass('off-' + prereq).addClass(prereq)

    $(relevantIDsClasses).trigger("dependencies:update");