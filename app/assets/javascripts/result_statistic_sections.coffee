# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->

    timers = {}

    submitForm = ( form ) ->
      ->
        form.submit()

    $( 'form.edit_record :input' ).keyup ( e ) ->
      e.preventDefault()

      # Ignore 'keyup' for a list of keys.
      code = e.keyCode || e.which;
      # 9: tab; 16: shift; 37: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 224: cmd
      if code in [9, 16, 18, 37, 38, 39, 40, 224]
        return

      $form = $( this ).closest( 'form' )

      # Use this to keep track of the different timers.
      formId = $form.attr( 'id' )

      # Mark form as 'dirty'.
      $form.addClass( 'dirty' )

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )

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
        $( '.nested-fields.comparate-groups' )
          .find( '.nested-fields.comparates' )
          .first()
          .after( $( '<div style="text-align: center; font-weight: normal;">vs.</div>' ) )

        if $( '.wac-comparate-fields' ).length == 2
          $( '.wac-comparate-fields:eq(1)' ).find( 'select option' ).filter( ->
            return this.text.includes( '(Baseline)' )
          ).attr('selected', true)

        $( '.links.add-comparison a' ).addClass( 'disabled' )

        # This creates a new cell at the end of the header row and moves the 'add comparison' link into it.
        # At the moment this isn't useful because we can't have the form span multiple row cells. Perhaps
        # using simple html form would work, but it doesn't seem to work with slim templating engine.
        #$( this ).closest( 'tr' ).append( $( '<th>' ).append( $( '.links.add-comparison' ) ) )

        return

  return # END do ->
return # END turbolinks:load
