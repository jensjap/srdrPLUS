# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->
    #$(window).trigger('load.zf.sticky')
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

    ## TASK MANAGEMENT - see if we can only run this stuff on the correct tab
    $( '.project_tasks_projects_users_roles select' ).select2()

    ## CITATION MANAGEMENT - see if we can only run this stuff on the correct tab
    list_options = { valueNames: [ 'citation-title', 'citation-authors', 'citation-numbers', 'citation-journal', 'citation-journal-date', 'citation-abstract', 'citation-abstract' ] }


    ##### DYNAMICALLY LOADING CITATIONS
    citationList = new List( 'citations', list_options )
    list_index = 0

    append_citations = ( page ) ->
      $.ajax $( '#citations-url' ).text(),
        type: 'GET'
        dataType: 'json'
        data: { page : page }
        error: (jqXHR, textStatus, errorThrown) ->
          toaster.error( 'Could not get citations' )
        success: (data, textStatus, jqXHR) ->
          to_add = []
          for c in data[ 'results' ]
            #console.log c
            to_add.push { 'citation-title': c[ 'name' ],\
              'citation-abstract': c[ 'abstract' ],\
              'citation-authors': ( c[ 'authors' ].map ( author ) -> author[ 'name' ] ),\
              'citation-numbers': c[ 'pmid' ] || "NO-PMID",\
              'citation-journal': c[ 'journal' ][ 'name' ],\
              'citation-journal-date': c[ 'journal'][ 'publication_date' ],\
              'citations-project-id': c[ 'citations_project_id' ] }
          if page == 1
            citationList.clear()
          citationList.add to_add, ( items ) ->
            for item in items
              console.log item
              #console.log $( '<input type="hidden" value=%%%CITATION_PROJECT_ID%%% name="project[citations_projects_attributes][%%%INDEX%%%][id]" id="project_citations_projects_attributes_%%%INDEX%%%_id">'.replace( /%%%CITATION_PROJECT_ID%%%/g, c[ 'citations_project_id' ] ).replace( /%%%INDEX%%%/g, list_index.toString() ) ).insertAfter( item.elm )
              $( '<input type="hidden" value=%%%CITATION_PROJECT_ID%%% name="project[citations_projects_attributes][%%%INDEX%%%][id]" id="project_citations_projects_attributes_%%%INDEX%%%_id">'.replace( /%%%CITATION_PROJECT_ID%%%/g, item.values()[ 'citations-project-id' ] ).replace( /%%%INDEX%%%/g, list_index.toString() ) ).insertAfter( item.elm )
              $( item.elm ).find( '#project_citations_projects_attributes_0__destroy' )[ 0 ].outerHTML = '<input type="hidden" name="project[citations_projects_attributes][%%%INDEX%%%][_destroy]" id="project_citations_projects_attributes_%%%INDEX%%%__destroy" value="false">'.replace( /%%%INDEX%%%/g, list_index.toString() )
                
              list_index++
            citationList.reIndex()
            citationList.sort( 'citation-numbers', { order: 'desc', alphabet: undefined, insensitive: true, sortFunction: undefined } )
            Foundation.reInit( $( '#citations-projects-list' ) )

          #citationList.add {  'citation-title': "TEST!", 'citation-authors': "TEST!", 'citation-numbers': "TEST!", 'citation-journal': "TEST!", 'citation-journal-date': "TEST!" }
          if data[ 'pagination' ][ 'more' ] == true
            append_citations(  page + 1 )
            
    append_citations( 1 )

    $( '#sort-select' ).on "change", () ->
      $( '#sort-button' ).attr( 'data-sort', $( this ).val() )

    #$( '#cp-insertion-node' ).on 'cocoon:before-remove', ( e, citation ) ->
      #$(this).data('remove-timeout', 1000)
      #citation.slideUp('slow')
    $( '#cp-insertion-node' ).on 'cocoon:before-insert', ( e, citation ) ->
      $( '.cancel-button' ).click()
      #citation.slideDown('slow')
    $( '#citations' ).find( '.list' ).on 'cocoon:after-remove', ( e, citation ) ->
      $( '#citations-form' ).submit()
#    $( '#citations' ).find( '.list' ).on 'cocoon:before-remove', ( e, citation ) ->
#      remove_button = $( citation ).find( '.remove-button' )
#      if not $( remove_button ).hasClass( 'confirm' )
#        e.preventDefault()
#        $( remove_button ).addClass( 'confirm' )
#        setTimeout ( ->
#          $( remove_button ).removeClass( 'confirm' )
#      ), 5000
#      else
#        $(this).data('remove-timeout', 1000)
#        citation.slideUp('slow')

#    setup_remove_button = ( remove_button ) ->
#      remove_button.addEventListener "click", ( e ) ->
#        if not $( remove_button ).hasClass( 'confirm' )
#          $( remove_button ).addClass( 'confirm' )
#          setTimeout ( ->
#            $( remove_button ).removeClass( 'confirm' )
#        ), 1000
#
#    $.map( $( '.remove-button' ), setup_remove_button )

    #projects_users_roles_data_url = $( '.project_tasks_projects_users_roles' ).attr('data_url')
    #@console.log projects_users_roles_data_url
    #$.ajax projects_users_roles_data_url,
    #  type: 'GET'
    #  dataType: 'json'
    #  success: (data) ->
    #    $( '.project_tasks_projects_users_roles select' ).select2
    #      data: data['results']
    #$( '.citation_select' ).select2
    #  ajax:
    #    url: '/api/v1/citations',
    #    dataType: 'json'
    #    delay: 250
    #    data: (params) ->
    #      console.log params
    #      q: params.term
    #      page: params.page || 1
    #    processResults: (data, params) ->
    #      # The server may respond with params.page, set it to 1 if not.
    #      params.page = params.page || 1
    #      results: $.map(data.items, (i) ->
    #        id: i.id
    #        text: i.name
    #      )
    #  width: '75%'

      # Cocoon listeners.
    #$( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
    #  $( insertedItem ).addClass( 'added-item' )
    #  $( insertedItem ).find( 'citation-select' ).select2
    #    ajax:
    #      url: '/api/v1/citations',
    #      dataType: 'json'
    #      delay: 250
    #      data: (params) ->
    #        console.log params
    #        q: params.term
    #        page: params.page || 1
    #      processResults: (data, params) ->
    #        # The server may respond with params.page, set it to 1 if not.
    #        params.page = params.page || 1
    #        results: $.map(data.items, (i) ->
    #          id: i.id
    #          text: i.name
    #        )
    #    width: '75%'

    $( '.tasks-container' ).on 'cocoon:before-insert', ( e, insertedItem ) ->
      insertedItem.fadeIn 'slow'
      insertedItem.css('display', 'flex')
    # Bind select2 to degree selection.
    $( '.tasks-container' ).on 'cocoon:after-insert', ( e, insertedItem ) ->
      insertedItem.addClass( 'new-task' )
      $( insertedItem ).find( '.project_tasks_projects_users_roles select' ).select2()
      #$( insertedItem ).addClass( 'added-citation-item' )

    $( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
      $( insertedItem ).find( '.AUTHORS select' ).select2
        minimumInputLength: 0
        #closeOnSelect: false
        ajax:
          url: '/api/v1/authors.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1
      $( insertedItem ).find( '.KEYWORDS select' ).select2
        minimumInputLength: 0
        #closeOnSelect: false
        ajax:
          url: '/api/v1/keywords.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1
      $( insertedItem ).find( '.citation-select' ).select2
        minimumInputLength: 0
        ajax:
          url: '/api/v1/citations/titles.json',
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

      $( insertedItem ).find( '.save-citation' ).on 'click', () ->
        $( '#citations-form' ).submit()
        
    $( '#citations-form' ).bind "ajax:success", ( status ) ->
      append_citations( 1 )
      toastr.success('Save successful!')
      $( '.cancel-button' ).click()
      #alert 'Save successful'
    $( '#citations-form' ).bind "ajax:error", ( status ) ->
      toastr.error('Could not save changes')
      #alert 'Save failed'

      


#templateResult: formatResult
        #templateSelection: formatResultSelection
    
#      # Cocoon listeners.
#      .on 'cocoon:before-insert', ( e, insertedItem ) ->
#        insertedItem.fadeIn 'slow'
#
#      .on 'cocoon:after-insert', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      .on 'cocoon:before-remove', ( e, insertedItem ) ->
#        #!!! This isnt' working. Immediately disappears.
#        $( this ).data 'remove-timeout', 1000
#        insertedItem.fadeOut 'slow'
#
#      .on 'cocoon:after-remove', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      # Abide listeners.
#      # Make form errors visible on the tab links.
#      .on 'invalid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( '<span style="color: red;">(*) Key Question(s)</span>' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( '<span style="color: red;">(*) Project Information</span>' )
#
#      .on 'valid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( 'Key Question(s)' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( 'Project Information' )

#    change = ->
#      $("form input, form textarea").change( ->
#        $('a').click( ->
#          confirm('Unsaved changes. Are you sure?')
#        )
#      )
#
#    $(document).ready(change)
#
#    # the page has been parsed and changed to the new version and on DOMContentLoaded
#    $(document).on('page:change', change)

#    # Set the field to display from the result set.
#    formatResultSelection = (result, container) ->
#      result.text
#
#    # Markup result.
#    formatResult = (result) ->
#      if result.loading
#        return result.text
#      markup = '<span>'
#      if ~result.text.indexOf 'Pirate'
#        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
#      if ~result.text.indexOf 'New item: '
#        #!!! Maybe add some styling.
#        markup += ''
#      markup += result.text
#      if result.suggestion
#        markup += ' (suggested by ' + result.suggestion.first_name + ')'
#      markup += '</span>'
#      markup
#
#    # Bind select2 to key question selection.
#    $( '#project_key_question_ids' ).select2
#      minimumInputLength: 0
#      ajax:
#        url: '/projects/' + gon.project_id + '/key_questions.json'
#        dataType: 'json'
#        delay: 250
#        data: (params) ->
#          q: params.term
#          page: params.page
#        processResults: (data, params) ->
#          # The server may respond with params.page, set it to 1 if not.
#          params.page = params.page || 1
#          results: $.map(data.items, (i) ->
#            id: i.id
#            text: i.name
#            suggestion: i.suggestion
#          )
#      escapeMarkup: (markup) ->
#        markup
#      templateResult: formatResult
#      templateSelection: formatResultSelection

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
