document.addEventListener 'turbolinks:load', ->

  return unless $( '.assignments' ).length > 0

  do ->

      send_new_option = ( option_type, label_type ) ->
        $( '.add-option' ).click()
        new_option = $( '.option-fields' ).last()
        $( new_option ).find( 'input.option-type:radio[value="' + option_type + '"]' ).prop( 'checked', true )

        $( new_option ).find( 'input.label-type:radio[value="' + label_type + '"]' ).prop( 'checked', true )

      find_existing_option = ( option_type, label_type ) ->
        if label_type
          return $( '.option-fields:has(input.option-type:radio:checked[value="' + option_type + '"]):has(input.label-type:radio:checked[value="' + label_type + '"])' )
        else
          return $( '.option-fields:has(input.option-type:radio:checked[value="' + option_type + '"])' )

      require_option_handler = ( event ) ->
        option_type = $( event.target ).attr( 'option-type' )
        label_type = $( event.target ).attr( 'label-type' )
        existing_option = find_existing_option( option_type, label_type )
        if $( event.target ).hasClass( 'success' )
          $( existing_option ).find( '.remove-option' ).click()
          #$( '.send-options-button' ).click()
        else if existing_option.length == 0 or $( existing_option ).is( ':hidden' )
          send_new_option( option_type, label_type )
          #$( '.send-options-button' ).click()
        $( event.target ).toggleClass( 'success' )

#      switch_option_handler = ( event ) ->
#        option_type = $( event.target ).attr( 'option-type' )
#        if not $( event.target ).hasClass( 'secondary' )
#          existing_option = find_existing_option( option_type, null )
#          if $( event.target ).hasClass( 'off-button' )
#            $( existing_option ).find( '.remove-option' ).click()
#            #$( '.send-options-button' ).click()
#            $( event.target ).parent().find( '.on-button' ).toggleClass( 'secondary' )
#          else if $( event.target ).hasClass( 'on-button' )
#            if existing_option.length == 0 or $( existing_option ).is( ':hidden' )
#              send_new_option( option_type, null )
#            $( event.target ).parent().find( '.off-button' ).toggleClass( 'secondary' )
#          $( event.target ).toggleClass( 'secondary' )

      switch_option_handler = ( event ) ->
        option_type = $( event.target ).attr( 'option-type' )
        switch_value = $( event.target ).is( ':checked' )
        console.log $( event.target ).val()
        existing_option = find_existing_option( option_type, null )
        if switch_value == false
          $( existing_option ).find( '.remove-option' ).click()
        else
          if existing_option.length == 0 or $( existing_option ).is( ':hidden' )
              send_new_option( option_type, null )

      $( '.options-table .require-button' ).on( 'click', require_option_handler )
      $( '.options-table .switch input' ).on( 'change', switch_option_handler )

    return # END do ->

  return # END turbolinks:load
