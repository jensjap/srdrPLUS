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

      $( '#yes-button' ).removeClass( 'secondary' )
      $( '#no-button' ).removeClass( 'secondary' )
      $( '#maybe-button' ).removeClass( 'secondary' )
      if obj.index > 0
        if current_citation.label.value == 'yes'
          $( '#yes-button' ).addClass( 'secondary' )
        else if current_citation.label.value == 'no'
          $( '#no-button' ).addClass( 'secondary' )
        else if current_citation.label.value == 'maybe'
          $( '#maybe-button' ).addClass( 'secondary' )
      return

##### send_label #####
    send_label = ( obj, label_value ) ->
      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      is_patch = false
      if obj.index > 0 || obj.history[ obj.index ].label
        is_patch = true

      label_url = $( '#labels-url' ).text()
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
            value: label_value
            citations_project_id: current_citation.citations_project_id
          }
        }
        success:
          ( data ) ->
            parent.current_citation.label = { id: data.id, value: label_value }
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
    update_label = ( obj, index, label_value ) ->
      obj.index = index
      send_label( obj, label_value )

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
      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { citations: citations, history: history, index: 0, done: 'false', history_page: 0 }
      next_citation( state_obj )
      #add_breadcrumb( state_obj )
      state_obj.index = 0
      #update_index( state_obj, 0 )
      update_info( state_obj )
      update_arrows( state_obj )
      $('#switch-button').val('OFF')

      $( '#yes-button' ).click ->
        $( "#label-input[value='yes']" ).prop( 'checked', true )
        send_label( state_obj, 'yes' )

      $( '#maybe-button' ).click ->
        $( "#label-input[value='maybe']" ).prop( 'checked', true )
        send_label( state_obj, 'maybe' )

      $( '#no-button' ).click ->
        $( "#label-input[value='no']" ).prop( 'checked', true )
        send_label( state_obj, 'no' )

      next_button = $( '#next-button' )
      previous_button = $( '#previous-button' )
      switch_button = $( '#switch-button' )

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

      # pagination buttons
      $( '#next-page' ).click (e) -> 
        console.log( state_obj )
        get_history_page( state_obj, state_obj.history_page + 1 ) 

      $( '#prev-page' ).click (e) -> 
        get_history_page( state_obj, state_obj.history_page - 1 ) 
      return

##### get_history_page #####
    get_history_page = ( obj, page_index ) -> 
      page_size = 10
      if obj.history.length < ( page_index + 1) * page_size
        console.log( "loyloy" )
        start = obj.history.length
        count = page_index * page_size - obj.history.length
        $.ajax {
          type: 'GET'
          url: $( '#history-json-url' ).text()
          data: { count: count, start: start }
          success:
            ( data ) ->
              obj.history = obj.history.concat( data.labeled_citations_projects )
              switch_to_list( obj.history.slice( page_index * page_size, ( page_index + 1 ) * page_size ) )
              obj.history_page = page_index
              console.log( data )
        }
      else
        switch_to_list( obj.history.slice( page_index * page_size, ( page_index + 1 ) * page_size ) )
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

      $( '#breadcrumb-group' ).append( button );
      obj.history[ obj.index ].breadcrumb_id = breadcrumb_id
      obj.history[ obj.index ].id = id
      return

##### update_breadcrumb #####
    update_breadcrumb = ( citation ) ->
      button = $( '#' + citation.breadcrumb_id )
      label = citation.label.value
      button.removeClass( 'success alert' )
      if label == 'yes'
        button.addClass( 'success' )
      else if label == 'no'
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
    switch_to_list = ( history_elements ) ->
      $( '#citations-list-elements' ).empty()
      next_index = 0
      for c in history_elements
        citation_info =
          $( '<div></div>' ).attr( { id: 'citation-info-' + c.id } )
        citation_element =
          $( '<div></div>' ).attr( { id: 'citation-element-' + c.id, class: 'callout', index: next_index } )
        citation_title =
          $( '<b>' + c.name + '<b/>' ).attr( { id: '#citation-element-title-' + c.breadcrumb_id } )
        if c.abstract.length > 400
          citation_abstract =
            $( '<div>' + c.abstract.slice(0,400) + '...<div/>' ).attr( { id: '#citation-element-abstact-' + c.breadcrumb_id } )
        else
          citation_abstract =
            $( '<div>' + c.abstract + '<div/>' ).attr( { id: '#citation-element-abstact-' + c.breadcrumb_id } )


        #set up buttons
        buttons_wrapper =  $( '<div><div/>' ).attr( { id: 'buttons-wrapper' + c.id } )
        citation_buttons =
          $( '<div><div/>' ).attr( { id: 'citation-buttons-' + c.id, class: 'button-group' } )
        citation_button_yes =
          $( '<div>Yes</div>' ).attr( { id: 'citation-button-yes-' + c.id, class: 'button', index: next_index } )
        citation_button_maybe =
          $( '<div>Maybe</div>' ).attr( { id: 'citation-button-maybe-' + c.id, class: 'button', index: next_index } )
        citation_button_no =
          $( '<div>No</div>' ).attr( { id: 'citation-button-no-' + c.id, class: 'button', index: next_index } )

        # button click events
        citation_button_yes.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr("index"), 'yes' )

        citation_button_no.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr("index"), 'no' )

        citation_button_maybe.click (e) ->
          e.stopPropagation()
          update_label( obj, $(this).attr("index"), 'maybe' )

        # set click behavior
        citation_element.click ->
          #update_index( obj, $(this).attr("index") )
          obj.index = $(this).attr("index")
          update_info( obj )
          update_arrows( obj )
          switch_to_screening( obj )


        # for layout
        buttons_wrapper.css('float','right')
        citation_element.addClass('row')
        citation_info.addClass('columns medium-9')
        citation_buttons.addClass('columns medium-3')

        # highlight button based on label value
        if c.label?
          if c.label.value == 'yes'
            citation_button_yes.addClass( 'success' )
            citation_button_no.addClass( 'hollow' )
            citation_button_maybe.addClass( 'hollow' )
          else if c.label.value == 'no'
            citation_button_yes.addClass( 'hollow' )
            citation_button_no.addClass( 'alert' )
            citation_button_maybe.addClass( 'hollow' )
          else if c.label.value == 'maybe'
            citation_button_yes.addClass( 'hollow' )
            citation_button_no.addClass( 'hollow' )
            citation_button_maybe.addClass( 'secondary' )

        # place divs
        citation_info.append( citation_title )
        citation_info.append( citation_abstract )
        citation_element.append( citation_info )
        buttons_wrapper.append( citation_button_yes )
        buttons_wrapper.append( citation_button_maybe )
        buttons_wrapper.append( citation_button_no )
        citation_buttons.append( buttons_wrapper )
        citation_element.append( citation_buttons )
        $( '#citations-list-elements' ).append( citation_element )
        next_index++

      #hide regular view, show list view
      $( '#citations-list' ).show()
      $( '#screen-div' ).hide()

##### switch_to_screening #####
    switch_to_screening = ( obj ) ->
      $( '#citations-list-elements' ).empty()
      $( '#citations-list' ).hide()
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

  return # END do ->
return # END turbolinks:load
