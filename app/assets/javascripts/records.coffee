# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->

    timers = {}

    submitForm = ( form ) ->
      ->
        form.submit()

    # Select Drop Down and Radio
    $( 'form.edit_record select, form.edit_record input[type="checkbox"], form.edit_record input[type="radio"]' ).change ( e ) ->
      e.preventDefault()

      $form = $( this ).closest( 'form' )

      # Use this to keep track of the different timers.
      formId = $form.attr( 'id' )

      # Mark form as 'dirty'.
      $form.addClass( 'dirty' )

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )

    # Text Field.
    $( 'form.edit_record input' ).keyup ( e ) ->
      e.preventDefault()

      # Ignore 'keyup' for a list of keys.
      code = e.keyCode || e.which;
      # 9: tab; 16: shift; 37: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 91: cmd
      console.log code
      if code in [9, 16, 18, 37, 38, 39, 40, 91]
        return

      $form = $( this ).closest( 'form' )

      # Use this to keep track of the different timers.
      formId = $form.attr( 'id' )

      # Mark form as 'dirty'.
      $form.addClass( 'dirty' )

      if formId of timers
        clearTimeout( timers[formId] )
      timers[formId] = setTimeout( submitForm( $form ), 750 )
