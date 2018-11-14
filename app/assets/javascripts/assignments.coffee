# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->
  do ->
    return unless $(".assignments.screen").length > 0
    #if (window.location.pathname != '/info.php') 

##### get_c_p #####
    #get a list of unlabeled_citations from server
    get_c_p = ( obj ) ->
      if obj.citations.length < 5
        $.ajax {
          type: 'GET'
          url: $( '#screen-assignment-json-url' ).text()
          data: { count: '10' }
          success:
            ( data ) ->
              obj.citations = data.unlabeled_citations_projects
              obj.history = data.labeled_citations_projects
              if data.unlabeled_citations_projects.length == 0
                toastr.warning( 'No more citations to label' )
        }
      return

##### nothing_to_label #####
    nothing_to_label = ( obj ) ->
      interval_id = setInterval(
        ->
          get_c_p( obj )
          if obj.citations.length == 0
            $( '#citation-row' ).hide()
            $( '#end-message' ).show()
          else
            $( '#citation-row' ).show()
            $( '#end-message' ).hide()
            clearInterval( interval_id )
      , 1000 )

##### next_citation #####
    #gets the first citation from citations and updates index with it
    next_citation = ( obj ) ->
      if obj.citations.length == 0
        nothing_to_label( obj )
        return
      obj.history.unshift obj.citations.shift()
      return

##### update_info #####
    update_info = ( obj ) ->
      current_citation = obj.history[ obj.index ]

      $( '#citation-name' ).text( current_citation.name )
      $( '#citation-abstract' ).text( current_citation.abstract )
      $( '#citation-pmid' ).text( current_citation.pmid )
      $( '#citation-refman' ).text( current_citation.refman )
      if $( '#journal-visible' ).text() != 'false'
        $( '#journal-name' ).text( current_citation.journal.name )
        $( '#journal-date' ).text( current_citation.journal.publication_date )
      else
        $( '#journal-div' ).hide()

      if $( '#authors-visible' ).text() != 'false'
        $( '#citation-authors' ).empty()
        s = true
        for k in current_citation.authors
          if s
            s = false
            $( '#citation-authors' ).append( k.name )
          else
            $( '#citation-authors' ).append( ', ' + k.name)
      else
        $( '#authors-div' ).hide()

      $( '#citation-keywords' ).empty()
      s = true
      for k in current_citation.keywords
        if s
          s = false
          $( '#citation-keywords' ).append( k.name )
        else
          $( '#citation-keywords' ).append( ', ' + k.name)

      ## TAGGINGS
      root_url = $( '#root-url' ).text()
      $( '#tags-list' ).empty()
      for t in current_citation.taggings
        tag = $( '<div class="tag" >' + t.tag.name + ' </div>' )
        delete_tag_link = $( '<a id="delete-tag-'+ t.id + '" tagging-id="' + t.id + '">delete</a>' )
        delete_tag_link.click ->
          $.ajax {
            type: 'DELETE'
            url: root_url + '/api/v1/taggings/' + $( this ).attr( 'tagging-id' )
            data: {
              utf8: '✓'
              authenticity_token: $( '#authenticity-token' ).text()
            }
            success:
              () ->
                toastr.success( 'Tag successfully deleted' )
            error:
              () ->
                toastr.error( 'ERROR: Could not delete tag' )
          }

        $( tag ).append( delete_tag_link )
        $( '#tags-list' ).append( tag )

      ## CREATE A NEW TAGGING
      $( '#tag-select select' ).select2
        minimumInputLength: 0
        #closeOnSelect: false
        ajax:
          url: $( '#tags-url' ).text()
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

      $( '#tag-select select' ).on 'change', ->
        $.ajax {
          type: 'POST'
          url: root_url + '/api/v1/taggings'
          dataType: 'json'
          data: {
            utf8: '✓'
            authenticity_token: $( '#authenticity-token' ).text()
            tagging: {
              tag_id: $( this ).val()
              projects_users_role_id: obj[ 'projects_users_role_id' ]
              taggable_id: current_citation.citations_project_id
              taggable_type: "CitationsProject"
            }
          }
          success:
            () ->
              toastr.success( 'Tag successfully created' )
          error:
            () ->
              toastr.error( 'ERROR: Could not create tag' )
        }

      ## NOTES
      root_url = $( '#root-url' ).text()
      $( '#notes-list' ).empty()
      for n in current_citation.notes
        note = $( '<div class="note" >' + n.value + ' </div>' )
        delete_note_link = $( '<a id="delete-note-'+ n.id + '" note-id="' + n.id + '">delete</a>' )
        delete_note_link.click ->
          $.ajax {
            type: 'DELETE'
            url: root_url + '/api/v1/notes/' + $( this ).attr( 'note-id' )
            data: {
              utf8: '✓'
              authenticity_token: $( '#authenticity-token' ).text()
            }
            success:
              () ->
                toastr.success( 'Note successfully deleted' )
            error:
              () ->
                toastr.error( 'ERROR: Could not delete note' )
          }

        $( note ).append( delete_note_link )
        $( '#notes-list' ).append( note )

      ## CREATE A NEW NOTE
      $( '#save-note-button' ).on 'click', ->
        $.ajax {
          type: 'POST'
          url: root_url + '/api/v1/notes'
          dataType: 'json'
          data: {
            utf8: '✓'
            authenticity_token: $( '#authenticity-token' ).text()
            note: {
              value: $( '#note-textbox' ).val()
              projects_users_role_id: obj[ 'projects_users_role_id' ]
              notable_id: current_citation.citations_project_id
              notable_type: "CitationsProject"
            }
          }
          success:
            () ->
              toastr.success( 'Note successfully created' )
          error:
            () ->
              toastr.error( 'ERROR: Could not create note' )
        }

#      ## REASONS
#      root_url = $( '#root-url' ).text()
#      $( '#reasons-list' ).empty()
#      for n in obj.reasons
#        note = $( '<div class="note" >' + n.value + ' </div>' )
#        delete_note_link = $( '<a id="delete-note-'+ n.id + '" note-id="' + n.id + '">delete</a>' )
#        delete_note_link.click ->
#          $.ajax {
#            type: 'DELETE'
#            url: root_url + '/api/v1/notes/' + $( this ).attr( 'note-id' )
#            data: {
#              utf8: '✓'
#              authenticity_token: $( '#authenticity-token' ).text()
#            }
#            success:
#              () ->
#                toastr.success( 'Note successfully deleted' )
#            error:
#              () ->
#                toastr.error( 'ERROR: Could not delete note' )
#          }
#
#        $( note ).append( delete_note_link )
#        $( '#notes-list' ).append( note )
#
#      ## CREATE A NEW REASON
#      $( '#save-note-button' ).on 'click', ->
#        $.ajax {
#          type: 'POST'
#          url: root_url + '/api/v1/notes'
#          dataType: 'json'
#          data: {
#            utf8: '✓'
#            authenticity_token: $( '#authenticity-token' ).text()
#            note: {
#              value: $( '#note-textbox' ).val()
#              projects_users_role_id: obj[ 'projects_users_role_id' ]
#              notable_id: current_citation.citations_project_id
#              notable_type: "CitationsProject"
#            }
#          }
#          success:
#            () ->
#              toastr.success( 'Note successfully created' )
#          error:
#            () ->
#              toastr.error( 'ERROR: Could not create note' )
#        }

      $( '#yes-button' ).removeClass( 'secondary' )
      $( '#no-button' ).removeClass( 'secondary' )
      $( '#maybe-button' ).removeClass( 'secondary' )
      if obj.index > 0
        if current_citation.label.label_type_id == 1
          $( '#yes-button' ).addClass( 'secondary' )
        else if current_citation.label.label_type_id == 2
          $( '#no-button' ).addClass( 'secondary' )
        else if current_citation.label.label_type_id == 3
          $( '#maybe-button' ).addClass( 'secondary' )
      return

##### send_label #####
    send_label = ( obj, label_type_id ) ->


      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      is_patch = false
      if obj.index > 0 || obj.history[ obj.index ].label
        is_patch = true

      label_url = $( '#root-url' ).text() + '/labels'
      if is_patch
        label_url = label_url + '/' + obj.history[ obj.index ].label.id
      $.ajax {
        type: if is_patch > 0 then 'PATCH' else 'POST'
        url: label_url
        dataType: 'json'
        data: {
          utf8: '✓'
          authenticity_token: $( '#authenticity-token' ).text()
          label: {
            label_type_id: label_type_id
            citations_project_id: current_citation.citations_project_id
            projects_users_role_id: obj[ 'projects_users_role_id' ]
          }
        }
        success:
          ( data ) ->
            parent.current_citation.label = { id: data.id, label_type_id: label_type_id }
            #update_breadcrumb( current_citation )
            if $('#switch-button').val() == 'ON'
              get_history_page( obj, 0 )

      }
      get_c_p( obj )
      # if we are updating previous label increment index
      if obj.index > 0
        #update_index( obj, obj.index - 1 )
        obj.index = obj.index - 1
      # else add breadcrumb
      else if obj.citations.length > 0
        next_citation( obj )
        add_breadcrumb( obj )
        obj.index = 0
        #update_index( obj, 0 )
      update_info( obj )
      update_arrows( obj )
      return

##### update_label #####
    update_label = ( obj, index, label_type_id ) ->
      obj.index = index
      send_label( obj, label_type_id )

##### update_arrows #####
    update_arrows = ( obj ) ->
      if obj.index < obj.history.length - 1
        $( '#previous-button' ).removeClass( 'disabled' )
      else
        $( '#previous-button' ).addClass( 'disabled' )

      if obj.index > 0
        $( '#next-button' ).removeClass( 'disabled' )
      else
        $( '#next-button' ).addClass( 'disabled' )
      return

##### start_screening #####
    start_screening = ( citations, history ) ->
      #we need the projects_users_role_id
      projects_users_role_id = $( '#projects-users-role-id' ).text()

      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { projects_users_role_id: projects_users_role_id, citations: citations, history: history, index: 0, done: 'false', history_page: 0 }
      next_citation( state_obj )
      #add_breadcrumb( state_obj )
      state_obj.index = 0
      #update_index( state_obj, 0 )
      update_info( state_obj )
      update_arrows( state_obj )
      $( '#switch-button' ).val('OFF')

      $( '#yes-button' ).click ->
        send_label( state_obj, 1 )

      $( '#no-button' ).click ->
        send_label( state_obj, 2 )

      $( '#maybe-button' ).click ->
        send_label( state_obj, 3 )

      next_button = $( '#next-button' )
      previous_button = $( '#previous-button' )
      switch_button = $( '#switch-button' )
      tags_button = $( '#tags-button' )
      close_tags_button = $( '#close-tags-button' )

      next_button.click ->
        if !next_button.hasClass( 'disabled' )
          state_obj.index = state_obj.index - 1
          #update_index( state_obj, state_obj.index - 1 )
          update_arrows( state_obj )
          update_info( state_obj )

      previous_button.click ->
        if !previous_button.hasClass( 'disabled' )
          state_obj.index = state_obj.index + 1
          #update_index( state_obj, state_obj.index + 1 )
          update_arrows( state_obj )
          update_info( state_obj )

      # button to switch to list view
      switch_button.click ->
        if switch_button.val() == 'OFF'
          get_history_page( state_obj, 0 )
          switch_button.val( 'ON' )
        else
          switch_to_screening( state_obj )
          switch_button.val( 'OFF' )

      # button to get the tags modal
      tags_button.click ->
        switch_to_tags( )

      # button to close the tags modal
      close_tags_button.click ->
        switch_to_screening( )

      # pagination buttons
      $( '#next-page' ).click (e) ->
        get_history_page( state_obj, state_obj.history_page + 1 )

      $( '#prev-page' ).click (e) ->
        get_history_page( state_obj, state_obj.history_page - 1 )
      return

##### get_history_page #####
    get_history_page = ( obj, page_index ) ->
      page_size = 10

      if obj.history.length < ( page_index + 1 ) * page_size
        offset = obj.history.length - 1
        count = ( page_index + 1 ) * page_size - obj.history.length
        $.ajax {
          type: 'GET'
          url: $( '#history-json-url' ).text()
          data: { count: count, offset: offset }
          success:
            ( data ) ->
              obj.history = obj.history.concat( data.labeled_citations_projects )
              switch_to_list( obj, obj.history.slice( page_index * page_size, ( page_index + 1 ) * page_size ) )
              obj.history_page = page_index
        }
      else
        switch_to_list( obj, obj.history.slice( page_index * page_size, ( page_index + 1 ) * page_size ) )
        obj.history_page = page_index

##### add_breadcrumb #####
    add_breadcrumb = ( obj ) ->
      next_index = obj.history.length
      breadcrumb_id = 'breadcrumb_' + next_index
      id = next_index
      button = $( '<input/>' ).attr( { type: 'button', id: breadcrumb_id, class: 'button' } )
      button.click ->
        obj.index = obj.history.length - next_index
        #update_index( obj, obj.history.length - next_index )
        update_info( obj )
        update_arrows( obj )

      $( '#breadcrumb-group' ).append( button )
      obj.history[ obj.index ].breadcrumb_id = breadcrumb_id
      obj.history[ obj.index ].id = id
      return

##### update_breadcrumb #####
    update_breadcrumb = ( citation ) ->
      button = $( '#' + citation.breadcrumb_id )
      label = citation.label.label_type_id
      button.removeClass( 'success alert' )
      if label == 1
        button.addClass( 'success' )
      else if label == 2
        button.addClass( 'alert' )
      return

##### update_index #####
    update_index = ( obj, new_index ) ->
      old_breadcrumb_id = obj.history[ obj.index ].breadcrumb_id
      obj.index = new_index
      new_breadcrumb_id = obj.history[ new_index ].breadcrumb_id
      $( '#' + old_breadcrumb_id ).removeClass( 'hollow' )
      $( '#' + new_breadcrumb_id ).addClass( 'hollow' )
      return

##### switch_to_list #####
    switch_to_list = ( obj, history_elements ) ->
      $( '#citations-list-elements' ).empty()
      next_index = 0
      for c in history_elements
        info_wrapper =
          $( '<div><div/>' ).attr( { id: 'info-wrapper-' + c.citations_project_id, class: 'info-wrapper' } )
        citation_info =
          $( '<div></div>' ).attr( { id: 'citation-info-' + c.citations_project_id, class: 'citation-info' } )
        citation_element =
          $( '<div></div>' ).attr( { id: 'citation-element-' + c.citations_project_id, class: 'callout row', index: next_index } )
        citation_title =
          $( '<b>' + c.name + '<b/>' ).attr( { id: '#citation-element-title-' + c.citations_project_id } )
        if c.abstract.length > 400
          citation_abstract =
            $( '<div>' + c.abstract.slice(0,400) + '...<div/>' ).attr( { id: '#citation-element-abstact-' + c.citations_project_id } )
        else
          citation_abstract =
            $( '<div>' + c.abstract + '<div/>' ).attr( { id: '#citation-element-abstact-' + c.breadcrumb_id } )

        #set up buttons
        citation_buttons =
          $( '<div><div/>' ).attr( { id: 'citation-buttons-' + c.citations_project_id, class: 'button-group citation-buttons' } )
        citation_button_yes =
          $( '<div>Yes</div>' ).attr( { id: 'citation-button-yes-' + c.citations_project_id, class: 'button', index: next_index } )
        citation_button_maybe =
          $( '<div>Maybe</div>' ).attr( { id: 'citation-button-maybe-' + c.citations_project_id, class: 'button', index: next_index } )
        citation_button_no =
          $( '<div>No</div>' ).attr( { id: 'citation-button-no-' + c.citations_project_id, class: 'button', index: next_index } )

        # button click events
        citation_button_yes.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr('index'), 1 )

        citation_button_no.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr('index'), 2 )

        citation_button_maybe.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr('index'), 3 )

        # set click behavior
        citation_element.click ->
          #update_index( obj, $(this).attr('index') )
          obj.index = $(this).attr('index')
          update_info( obj )
          update_arrows( obj )
          switch_to_screening( obj )


        # highlight button based on label id
        if c.label?
          if c.label.label_type_id == 1
            citation_button_yes.addClass( 'success' )
            citation_button_no.addClass( 'hollow' )
            citation_button_maybe.addClass( 'hollow' )
          else if c.label.label_type_id == 2
            citation_button_yes.addClass( 'hollow' )
            citation_button_no.addClass( 'alert' )
            citation_button_maybe.addClass( 'hollow' )
          else if c.label.label_type_id == 3
            citation_button_yes.addClass( 'hollow' )
            citation_button_no.addClass( 'hollow' )
            citation_button_maybe.addClass( 'secondary' )

        # place divs
        citation_info.append( citation_title )
        citation_info.append( citation_abstract )
        info_wrapper.append( citation_info )

        citation_buttons.append( citation_button_yes )
        citation_buttons.append( citation_button_maybe )
        citation_buttons.append( citation_button_no )
        
        citation_element.append( citation_buttons )
        citation_element.append( info_wrapper )
        $( '#citations-list-elements' ).append( citation_element )
        next_index++

      #hide regular view, show list view
      $( '#pagination-buttons' ).show()
      $( '#citations-list' ).show()
      $( '#screen-div' ).hide()

##### switch_to_tags #####
    switch_to_tags = ( ) ->
      $( '#screen-div' ).hide()
      $( '#tags-modal' ).show()
    #  $( '#citations-list-elements' ).empty()
    #  next_index = 0
    #  for c in history_elements
    #    info_wrapper =  
    #      $( '<div><div/>' ).attr( { id: 'info-wrapper-' + c.citations_project_id, class: 'info-wrapper' } )
    #    citation_info =
    #      $( '<div></div>' ).attr( { id: 'citation-info-' + c.citations_project_id, class: 'citation-info' } )
    #    citation_element =
    #      $( '<div></div>' ).attr( { id: 'citation-element-' + c.citations_project_id, class: 'callout row', index: next_index } )
      return

##### switch_to_screening #####
    switch_to_screening = ( obj ) ->
      $( '#pagination-buttons' ).hide()
      $( '#citations-list-elements' ).empty()
      $( '#citations-list' ).hide()
      $( '#tags-modal' ).hide()
      $( '#screen-div' ).show()
      $( '#switch-button').val('OFF')


###################################
######  THIS IS THE START  ########
###################################

    $.ajax {
      type: 'GET'
      url: $( '#screen-assignment-json-url' ).text()
      data: { count: '10' }
      success:
        ( data ) ->
          $( '#screen-div' ).show()
          start_screening( data.unlabeled_citations_projects, data.labeled_citations_projects )
    }

    $( '#hide-me' ).hide()
    $( '#pagination-buttons' ).hide()

  return # END do ->
return # END turbolinks:load
