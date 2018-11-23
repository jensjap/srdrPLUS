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
              obj.options = data.options
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

##### lock_label #####
    lock_button = ( label, requirement ) ->
      button_to_lock = null
      if label == "Yes"
        button_to_lock = $( '#yes-button' )
      else if label == "No"
        button_to_lock = $( '#no-button' )
      else if label == "Maybe"
        button_to_lock = $( '#maybe-button' )
      else
        return

      if requirement == "REASON_REQUIRED"
        $( '#reason-select select' ).on 'change', ( ) ->
          if $( '#reason-select select option:checked' ).length == 0
            $( button_to_lock ).addClass( 'reason-lock' )
          else
            $( button_to_lock ).removeClass( 'reason-lock' )
            
          $( button_to_lock ).trigger 'change'

      else if requirement == "TAG_REQUIRED"
        $( '#tag-select select' ).on 'change', ( ) ->
          if $( '#tag-select select option:checked' ).length == 0
            $( button_to_lock ).addClass( 'tag-lock' )
          else
            $( button_to_lock ).removeClass( 'tag-lock' )

          $( button_to_lock ).trigger 'change'

      else if requirement == "NOTE_REQUIRED"
        $( 'textarea#note-textbox' ).on 'change', ( ) ->
          if !$( 'textarea#note-textbox' ).hasClass( 'note-saved' )
            $( button_to_lock ).addClass( 'note-lock' )
          else
            $( button_to_lock ).removeClass( 'note-lock' )

          $( button_to_lock ).trigger 'change'


      $( button_to_lock ).on 'change', ( ) ->
        if $( button_to_lock ).hasClass( 'note-lock' ) || $( button_to_lock ).hasClass( 'tag-lock' ) || $( button_to_lock ).hasClass( 'reason-lock' )
          $( button_to_lock ).addClass( 'disabled' )
        else
          $( button_to_lock ).removeClass( 'disabled' )
      return

        



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


      ## reset button colors
      $( '#yes-button' ).removeClass( 'success' )
      $( '#no-button' ).removeClass( 'alert' )
      $( '#maybe-button' ).removeClass( 'secondary' )

      ## APPLY REQUIRED OPTIONS
      for option in obj.options
        lock_button( option.label_type, option.type )

      ## TAGGINGS
      $( '#tag-select select' ).val( null )
      $( '#tag-select select' ).empty( )
      for t in current_citation.taggings
        tag_option = new Option( t.tag.name, t.tag.id, true, true )
        $( tag_option ).attr( 'tagging-id', t.id )
        $( '#tag-select select' ).append( tag_option )
        $( '#tag-select select' ).trigger
          type: 'select2:select'
          params: data: { id: t.tag.id, text: t.tag.name }
      $( '#tag-select select' ).trigger 'change'

      ## NOTES
      if !!current_citation.notes[ 0 ]
        $( 'textarea#note-textbox' ).val( current_citation.notes[ 0 ].value )
      else
        $( 'textarea#note-textbox' ).val( '' )
      if $( 'textarea#note-textbox' ).val() != ''
        $( 'textarea#note-textbox' ).addClass( 'note-saved' )
      $( 'textarea#note-textbox' ).trigger 'change'

      ## uncheck reasons
      $( '#reason-select select' ).val( null )
      $( '#reason-select select' ).empty()

      if obj.index > 0
        ## create options for existing reasons
        if !!current_citation.label and !!current_citation.label.labels_reasons
          for labels_reason in current_citation.label.labels_reasons
            reason_option = new Option( labels_reason.reason.name, labels_reason.reason.id, true, true )
            $( reason_option ).attr( 'labels-reason-id', labels_reason.id )
            $( '#reason-select select' ).append( reason_option )
            $( '#reason-select select' ).trigger
              type: 'select2:select'
              params: data: { id: labels_reason.reason.id, text: labels_reason.reason.name }

        if current_citation.label.label_type_id == 1
          $( '#yes-button' ).addClass( 'success' )
        else if current_citation.label.label_type_id == 2
          $( '#no-button' ).addClass( 'alert' )
        else if current_citation.label.label_type_id == 3
          $( '#maybe-button' ).addClass( 'secondary' )

      $( '#reason-select select' ).trigger 'change'
      return


##### send_label #####
    send_label = ( obj, label_type_id ) ->
      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      is_patch = false
      if obj.index > 0 || obj.history[ obj.index ].label
        is_patch = true

      label_params = {
            label_type_id: label_type_id
            citations_project_id: current_citation.citations_project_id
            projects_users_role_id: obj.projects_users_role_id
          }

      ## labels_reasons ##
      for reason_option in $( '#reason-select select option:checked' )
        label_params.labels_reasons_attributes ?= [ ]
        if !$( reason_option ).attr( 'labels-reason-id' )
          label_params.labels_reasons_attributes.push( { projects_users_role_id: obj.projects_users_role_id, reason_id: $( reason_option ).val() } )
      for reason_option in $( '#reason-select select option:not(:checked)' )
        label_params.labels_reasons_attributes ?= [ ]
        if $( reason_option ).attr( 'labels-reason-id' )
          label_params.labels_reasons_attributes.push( { id: $( reason_option ).attr( 'labels-reason-id' ), _destroy: true } )

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
          label: label_params

        }
        success:
          ( data ) ->
            parent.current_citation.label = { id: data.id, label_type_id: label_type_id, labels_reasons: data.labels_reasons }
            #update_breadcrumb( current_citation )
            if $('#switch-button').val() == 'ON'
              get_history_page( obj, 0 )
            toastr.success 'Label is created successfully'

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
        error:
          ( ) ->
            toastr.error 'ERROR: Could not create label'
      }
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
    start_screening = ( citations, history, options ) ->
      #we need the projects_users_role_id
      projects_users_role_id = $( '#projects-users-role-id' ).text()

      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { projects_users_role_id: projects_users_role_id, citations: citations, history: history, index: 0, done: 'false', history_page: 0, options: options }
      next_citation( state_obj )
      #add_breadcrumb( state_obj )
      state_obj.index = 0
      #update_index( state_obj, 0 )
      update_info( state_obj )
      update_arrows( state_obj )
      $( '#switch-button' ).val('OFF')

      $( '#yes-button' ).click ->
        if !$( this ).hasClass( 'disabled' )
          send_label( state_obj, 1 )

      $( '#no-button' ).click ->
        if !$( this ).hasClass( 'disabled' )
          send_label( state_obj, 2 )

      $( '#maybe-button' ).click ->
        if !$( this ).hasClass( 'disabled' )
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

      ## NOTE CREATION HANDLING
      timeoutId = null
      $('textarea#note-textbox').on 'input', () ->
        $( 'textarea#note-textbox' ).removeClass( 'note-saved' )
        clearTimeout( timeoutId )
        timeoutId = setTimeout ( ->
          is_patch = !!state_obj.history[ state_obj.index ].notes[ 0 ]
          $.ajax {
            type: if is_patch then 'PATCH' else 'POST'
            url: $( '#root-url' ).text() + '/api/v1/notes' + ( if is_patch then '/' + state_obj.history[ state_obj.index ].notes[ 0 ].id else '' )
            dataType: 'json'
            data: {
              utf8: '✓'
              authenticity_token: $( '#authenticity-token' ).text()
              note: {
                value: $( '#note-textbox' ).val()
                projects_users_role_id: state_obj.projects_users_role_id
                notable_id: state_obj.history[ state_obj.index ].citations_project_id
                notable_type: "CitationsProject"
              }
            }
            success:
              ( data ) ->
                if $( '#note-textbox' ).val() != ''
                  $( 'textarea#note-textbox' ).addClass( 'note-saved' )
                  $( 'textarea#note-textbox' ).trigger 'change'
                state_obj.history[ state_obj.index ].notes[ 0 ] = { id: data.id, value: $( '#note-textbox' ).val() }
                toastr.success( 'Note successfully saved' )
            error:
              () ->
                toastr.error( 'ERROR: Could not save note' )
          }

        ) , 1200

      ## TAGGING CREATION HANDLING
      $( '#tag-select select' ).select2
        minimumInputLength: 0
        #closeOnSelect: false
        ajax:
          url: ( ) -> $('root-url').text() + '/api/v1/assignments/' + $( '#assignment-id' ).text() + '/tags.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

      $( '#tag-select select' ).on 'select2:select', ( event ) ->
        tag_text = event.params.data.text
        tag_id = event.params.data.id
        tag_option_element = $( event.target ).find( 'option[value="' + tag_id + '"]' )[ 0 ]
        if !$( tag_option_element ).attr( 'tagging-id' )
          $.ajax {
            type: 'POST'
            url: $( '#root-url' ).text() + '/api/v1/taggings'
            dataType: 'json'
            data: {
              utf8: '✓'
              authenticity_token: $( '#authenticity-token' ).text()
              tagging: {
                tag_id: tag_id
                projects_users_role_id: state_obj.projects_users_role_id
                taggable_id: state_obj.history[ state_obj.index ].citations_project_id
                taggable_type: "CitationsProject"
              }
            }
            success:
              ( data ) ->
                state_obj.history[ state_obj.index ].taggings.push { id: data.id, tag: { id: tag_id, name: tag_text } }
                $( tag_option_element ).attr( 'tagging-id', data.id )
                toastr.success( 'Tag successfully created' )
            error:
              () ->
                toastr.error( 'ERROR: Could not create tag' )
          }

      $( '#tag-select select' ).on 'select2:unselect', ( event ) ->
        tag_id = event.params.data.id
        tag_option_element = $( event.target ).find( 'option[value="' + tag_id + '"]' )[ 0 ]
        if $( tag_option_element ).attr( 'tagging-id' )
          tagging_id = +$( tag_option_element ).attr( 'tagging-id' )

          $.ajax {
            type: 'DELETE'
            url: $( '#root-url' ).text() + '/api/v1/taggings/' + tagging_id
            data: {
              utf8: '✓'
              authenticity_token: $( '#authenticity-token' ).text()
            }
            success:
              () ->
                i = 0
                current_citation = state_obj.history[ state_obj.index ]
                for tagging in current_citation.taggings
                  if tagging.id == tagging_id
                    current_citation.taggings.splice( i, 1 )
                    break
                  i++
                toastr.success( 'Tag successfully deleted' )
            error:
              () ->
                toastr.error( 'ERROR: Could not delete tag' )
          }
      
      ## REASON HANDLING
      $( '#reason-select select' ).select2
        minimumInputLength: 0
        #closeOnSelect: false
        ajax:
          url: ( ) -> $('root-url').text() + '/api/v1/assignments/' + $( '#assignment-id' ).text() + '/reasons.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

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

##### update_reasons #####
    update_reasons = () ->
      ## REASONS
      root_url = $( '#root-url' ).text()
      projects_user_reasons = $( '#projects-user-reasons fieldset' )
      project_lead_reasons = $( '#project-lead-reasons fieldset' )

      $.ajax {
        type: 'GET'
        url: $('root-url').text() + '/api/v1/assignments/' + $( '#assignment-id' ).text() + '/reasons.json'
        success:
          ( data ) ->
            if data.results.projects_user_reasons?
              projects_user_reasons.empty()
              for reason in data.results.projects_user_reasons
                reason_element = $( '<input type="checkbox" value="' + reason.id + '" id="reason-' + reason.id + '" style="display: inline; margin-bottom: 0;">' )
                reason_label = $(  '<label for="reason-' + reason.id + '" style="display: inline;">' + reason.text + '</label><br>' )
                projects_user_reasons.append reason_element
                projects_user_reasons.append reason_label
            else
              projects_user_reasons.hide()

            if data.results.project_lead_reasons?
              project_lead_reasons.empty()
              for reason in data.results.project_lead_reasons
                reason_element = $( '<input type="checkbox" value="' + reason.id + '" id="reason-' + reason.id + '" style="display: inline; margin-bottom: 0;">' )
                reason_label = $(  '<label for="reason-' + reason.id + '" style="display: inline;">' + reason.text + '</label><br>' )
                project_lead_reasons.append reason_element
                project_lead_reasons.append reason_label
            else
              project_lead_reasons.hide()
        error:
          () ->
            toastr.error( 'ERROR: Could not fetch reasons' )
      }

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
          obj.index = +$(this).attr('index')
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
        
        citation_element.append( info_wrapper )
        citation_element.append( citation_buttons )
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
          start_screening( data.unlabeled_citations_projects, data.labeled_citations_projects, data.options )
    }

    $( '#hide-me' ).hide()
    $( '#pagination-buttons' ).hide()

  return # END do ->
return # END turbolinks:load
