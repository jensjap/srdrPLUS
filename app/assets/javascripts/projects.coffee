document.addEventListener 'DOMContentLoaded', ->
  return if $('body.extractions.work').length > 0
  documentCode()

document.addEventListener 'extractionSectionLoaded', ->
  documentCode()

documentCode = ->
  return unless $( '.projects, .citations, .extractions, .build' ).length > 0
  # Ajax call to filter the project list. We want to return a function here
  # to prevent it from being called immediately. Wrapper is to allow passing
  # param without immediate function invocation.
  filterProjectList = ( order ) ->
    ->
      $.get {
          url: '/projects/filter?q=' + $( '#project-filter' ).val() + '&o=' + order,
          dataType: 'script'
      }
      return

  # Everytime a user types into the search field we send an ajax request to
  # filter the list. Use delay to delay the call.
  $( '#project-filter' ).keyup ( e ) ->
    e.preventDefault()
    currentOrder = $( '.toggle-sort-order button.button.active' ).data( 'sortOrder' )
    delay filterProjectList( currentOrder ), 750
    return

  # There's a short flicker when the button gains focus which is ugly.
  # We prevent it by calling e.preventDefault(). However, this must happen
  # on mousedown because that's when an item gains focus.
  $( '.toggle-sort-order button' ).mousedown ( e ) ->
    e.preventDefault()
    if $( this ).hasClass( 'active' )
      return
    nextOrder = $( '.toggle-sort-order button.button.disabled' ).data( 'sortOrder' )
    # Since filterProjectList returns a function, we to call it immediately.
    filterProjectList( nextOrder )()
    return

  # Activates the search slider on the project index page.
  $( 'button.search' ).mousedown ( e ) ->
    e.preventDefault()
    $( '.search-field' ).toggleClass 'expand-search'
    $( '#project-filter' ).focus()
    return

  # Iterate over each option and if any of them are "checked" go ahead and use that value.
  $( '.export-type-radio' ).each ( e ) ->
    if $( this ).is ':checked'
      export_button = $( this ).parents('.reveal').find( '.start-export-button' )
      link_string = $( export_button ).attr( 'href', $( this ).val() )
  # Update the option on change.
  $( '.export-type-radio' ).on 'change', ( e ) ->
    if $( this ).is ':checked'
      export_button = $( this ).parents('.reveal').find( '.start-export-button' )
      link_string = $( export_button ).attr( 'href', $( this ).val() )

  ########## IMPORTERS
  if $( 'body.projects.new' ).length == 1
    $( '#projects-users-container' ).on 'cocoon:after-insert', ( _, projectsUsersElem ) ->
      $( projectsUsersElem ).on 'cocoon:after-insert', ( _, insertedElem ) ->
        #$( '.key-questions-list' ).find( 'input.string' ).each ( i, kq_textbox ) ->
        #  op = new Option( $( kq_textbox ).val(), $( kq_textbox ).val(), false, false )
        #  $( insertedElem ).find( '.distiller-key-question-input' ).first().append op
        $( insertedElem ).find( '.distiller-section-input' ).select2( placeholder: "-- Select Section --", tags: true )

        # We want to copy key questions from existing section files after inserting a new section box
        $new_kq_input = $( insertedElem ).find( '.distiller-key-question-input' )
        if $( '.distiller-section-file-container select.distiller-key-question-input' ).length > 1
          $source_kq_input = $( '.distiller-section-file-container select.distiller-key-question-input' ).first()
          $source_kq_input.find( 'option' ).each ( _, kq_option ) ->
            $kq_option = $( kq_option )
            if $new_kq_input.find( 'option[value="' + $kq_option.val() + '"]' ).length == 0
              $new_kq_input.append( new Option( $kq_option.val(), $kq_option.val(), false, false ) )
            $new_kq_input.trigger 'change'

        $new_kq_input.select2( placeholder: "-- Select Key Question --", tags: true ).on 'change', ( e ) ->
          $isNew = $( this ).find( '[data-select2-tag="true"]' )
          if $isNew.length and $isNew.val() == $( this ).val()
            # find other kq select2's and add this kq to them as well
            $( '.distiller-section-file-container select.distiller-key-question-input' ).each ( _, kq_input ) ->
              $kq_input = $( kq_input )
              if $kq_input.find( 'option[value="' + $isNew.val() + '"]' ).length == 0
                $kq_input.append( new Option( $isNew.val(), $isNew.val(), false, false ) ).trigger 'change'
              $isNew.replaceWith new Option( $isNew.val(), $isNew.val(), false, true )

      # $( '.key-questions-list' ).on 'cocoon:after-remove', ( e, removedElem ) ->
      #   removed_kq_val = $( removedElem ).find( 'input.string' ).val()
      #   $( '.distiller-section-file-container' ).find( "select.distiller-key-question-input option[value=\'" + removed_kq_val + "\']" ).remove()
      #   $( '.distiller-section-file-container' ).trigger( 'change' )

      # $( '.key-questions-list' ).on 'cocoon:after-insert', ( e, insertedElem ) ->
      #   textbox = $( insertedElem ).find( 'input.string' )
      #   $( textbox ).val('New Key Question ' + $( '.key-questions-list' ).find('input.string').length.toString())
      #   $( textbox ).on 'input', ( input_e ) ->
      #     option_name = $( input_e.target ).attr( 'data-option-name' )
      #     textbox_val = $( input_e.target ).val()
      #     $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).each ( i, kq_input ) ->
      #       textbox_val = $( input_e.target ).val()
      #       old_option = $( kq_input ).find("option[value='"+option_name+"']")
      #       new_option = new Option( textbox_val, textbox_val, false, false )

      #       kq_select_val = $( kq_input ).val()
      #       if $( kq_input ).val() == $( old_option ).val()
      #         kq_select_val = $( new_option ).val()
      #       $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).append( new_option )
      #       $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).val( kq_select_val )
      #       $( old_option ).remove()
      #       $( '.distiller-section-file-container' ).trigger( 'change' )
      #       $( input_e.target ).attr( 'data-option-name' , $( new_option ).val() )
      #   newOption = new Option( $( textbox ).val(), $( textbox ).val(), false, false)
      #   $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).append( newOption ).trigger( 'change' )
      #   $( textbox ).attr('data-option-name', $( newOption ).val() )

    $( '#create-type' ).on 'change', ( e ) ->
      $( '.input.file input' ).val('')
      if $( e.target ).val() == "empty"
        $( '.remove-projects-user' ).trigger "click"
        $( '.submit' ).removeClass( 'hide' )
        $( '.submit-with-confirmation' ).addClass( 'hide' )
      else if $( e.target ).val() == "distiller"
        $( '#add-projects-user' ).trigger "click"
        $( '#distiller-add-references-file' ).trigger "click"
        $( '#distiller-add-section-file' ).trigger "click"
        $( '.submit' ).addClass( 'hide' )
        $( '.submit-with-confirmation' ).removeClass( 'hide' )
      else if $( e.target ).val() == "json"
        $( '.submit' ).addClass( 'hide' )
        $( '.submit-with-confirmation' ).removeClass( 'hide' )

  ########## TASK MANAGEMENT
  if $( 'body.projects.edit' ).length == 1
    $( '.project_tasks_projects_users_roles select' ).select2()
    #### LISTENERS
    $( '.tasks-container' ).on 'cocoon:before-insert', ( e, insertedItem ) ->
      insertedItem.fadeIn 'slow'
      insertedItem.css('display', 'flex')
    $( '.tasks-container' ).on 'cocoon:after-insert', ( e, insertedItem ) ->
      insertedItem.addClass( 'new-task' )
      $( insertedItem ).find( '.project_tasks_projects_users_roles select' ).select2()

    ######### PROJECTS USERS
    ## still inside projects edit view
    $( ".project_projects_users_user select" ).select2
      minimumInputLength: 0
      ajax:
        url: '/api/v1/users.json'
        dataType: 'json'
        delay: 100
        data: (params) ->
          q: params.term
          page: params.page || 1

    #### LISTENERS
    $( '#projects-users-table' ).on 'cocoon:after-insert', ( e, insertedItem ) ->
      $( insertedItem ).find( '.project_projects_users_user select' ).select2
        minimumInputLength: 0
        ajax:
          url: '/api/v1/users.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

  #### METHOD DESCRIPTION DROPDOWN
  $( '.projects.edit' ).find( '#project_method_description_select2' ).select2(
    tags: true,
    allowClear: true,
    placeholder: '-- Select or type other --'
  )