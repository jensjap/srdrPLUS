# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  return unless $( '.projects' ).length > 0

  do ->

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
    
    $( '.export-type-radio' ).on 'change', ( e ) ->
      if $( this ).is ':checked'
        export_button = $( this ).parents('.reveal').find( '.start-export-button' )
        link_string = $( export_button ).attr( 'href', $( this ).val() )

########## DISTILLER IMPORT
   # if $( 'body.projects.new' ).length == 1
   #   $( '#distiller-import-checkbox' ).on 'change', ( ) ->
   #     $( '.distiller-import-panel' ).toggleClass( 'hide' )
   #   $( '#json-import-checkbox' ).on 'change', ( ) ->
   #     $( '.json-import-panel' ).toggleClass( 'hide' )

    if $( 'body.projects.new' ).length == 1
      $( '#create-type' ).on 'change', ( e ) ->
        $( '.input.file input' ).val('')
        if $( e.target ).val() == "empty"
          $( '.distiller-import-panel' ).addClass( 'hide' )
          $( '.json-import-panel' ).addClass( 'hide' )
        else if $( e.target ).val() == "distiller"
          $( '.distiller-import-panel' ).removeClass( 'hide' )
          $( '.json-import-panel' ).addClass( 'hide' )
        else if $( e.target ).val() == "json"
          $( '.distiller-import-panel' ).addClass( 'hide' )
          $( '.json-import-panel' ).removeClass( 'hide' )

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
    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
