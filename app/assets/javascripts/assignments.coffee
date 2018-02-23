
document.addEventListener 'turbolinks:load', ->
  do ->
##### loyloy #####
    loyloy = ( obj, data ) ->
      console.log('loyloy')
      return

##### get_c_p #####
    #get a list of unlabeled_citations from server
    get_c_p = ( obj ) ->
      if obj.citations.length < 5
        $.ajax {
          type: 'GET'
          url: $( '#screen-assignment-json-url' ).text()
          success: 
            ( data ) -> 
              obj.citations = data.citations_projects 
        }
      return

##### nothing_to_label #####
    nothing_to_label = ( obj ) ->
      interval_id = setInterval( 
        -> 
          get_c_p( obj )
          if obj.citations.length == 0
            $( '#citation-row' ).hide()
            #$( '#labeling-group' ).hide()
            #$( '#arrow-group' ).hide()
            #$( '#breadcrumb-group' ).hide()
            $( '#end-message' ).show()
          else
            $( '#citation-row' ).show()
            #$( '#labeling-group' ).show()
            #$( '#arrow-group' ).show()
            #$( '#breadcrumb-group' ).show()
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
      #$( '#journal-name' ).text( current_citation.journal.name )
      #$( '#journal-date' ).text( current_citation.journal.publication_date )

      $( '#citation-authors' ).empty()
      for a in current_citation.authors
        author = document.createElement( 'li' )
        author.innerHTML = a.name
        $( '#citation-authors' ).append( author )

      $( '#citation-keywords' ).empty()
      for k in current_citation.keywords
        $( '#citation-keywords' ).append( k.name + ', ' )

      $( '#yes-button' ).removeClass( 'secondary' )
      $( '#no-button' ).removeClass( 'secondary' )
      $( '#maybe-button' ).removeClass( 'secondary' )
      if obj.index > 0
        if current_citation.label_value == 'yes'
          $( '#yes-button' ).addClass( 'secondary' )
        else if current_citation.label_value == 'no'
          $( '#no-button' ).addClass( 'secondary' )
        else if current_citation.label_value == 'maybe'
          $( '#maybe-button' ).addClass( 'secondary' )
      return

##### send_label #####
    send_label = ( obj, label_value ) ->
      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      is_patch = false
      if obj.index > 0 || obj.history[ obj.index ].label_value 
        is_patch = true

      label_url = $( '#labels-url' ).text()
      if is_patch
        label_url = label_url + '/' + obj.history[ obj.index ].label_id
      $.ajax {
        type: if is_patch > 0 then 'PATCH' else 'POST'
        url: label_url
        dataType: 'json'
        data: {
          utf8: '✓'
          authenticity_token: $( '#authenticity-token' ).text()
          label: {
            value: label_value
            citations_project_id: current_citation.id
          }
        }
        success:
          ( data ) -> 
            parent.current_citation.label_id = data.id
            parent.current_citation.label_value = label_value
            update_breadcrumb( current_citation )
      }  
      return

##### label_actions #####
    label_action = ( obj, label_value ) -> 
      send_label( obj, label_value )
      get_c_p( obj )
      # if we are updating previous label increment index
      if obj.index > 0
        update_index( obj, obj.index - 1 )
      # else add breadcrumb 
      else if obj.citations.length > 0
        next_citation( obj )
        add_breadcrumb( obj )
        obj.index = 1
        update_index( obj, 0 )
      update_info( obj )
      update_arrows( obj )
      return
      
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
    start_screening = ( citations ) ->
      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { citations: citations, history: [ ], index: 0, done: 'false' }
      next_citation( state_obj )
      add_breadcrumb( state_obj )
      update_index( state_obj, 0 )
      update_info( state_obj )
      update_arrows( state_obj )

      $( '#yes-button' ).click ->
        $( "#label-input[value='yes']" ).prop( 'checked', true )
        label_action( state_obj, 'yes' ) 

      $( '#maybe-button' ).click ->
        $( "#label-input[value='maybe']" ).prop( 'checked', true )
        label_action( state_obj, 'maybe' ) 

      $( '#no-button' ).click ->
        $( "#label-input[value='no']" ).prop( 'checked', true )
        label_action( state_obj, 'no' ) 

      next_button = $( '#next-button' ) 
      previous_button = $( '#previous-button' ) 

      next_button.click ->
        if !next_button.hasClass( 'disabled' )
          update_index( state_obj, state_obj.index - 1 )
          update_arrows( state_obj )
          update_info( state_obj )

      previous_button.click ->
        if !previous_button.hasClass( 'disabled' )
          update_index( state_obj, state_obj.index + 1 )
          update_arrows( state_obj )
          update_info( state_obj )
      return

##### add_breadcrumb #####
    add_breadcrumb = ( obj ) ->
      next_index = obj.history.length
      breadcrumb_id = 'breadcrumb_' + next_index
      button = $( '<input/>' ).attr( { type: 'button', id: breadcrumb_id, value: next_index, class: 'button' } ) 
      button.click -> 
        update_index( obj, obj.history.length - next_index )
        update_info( obj )
        update_arrows( obj )

      $( '#breadcrumb-group' ).append( button );  
      obj.history[ obj.index ].breadcrumb_id = breadcrumb_id
      return

##### update_breadcrumb #####
    update_breadcrumb = ( citation ) ->
      button = $( '#' + citation.breadcrumb_id ) 
      label = citation.label_value
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

    $( '#hide-me' ).hide()
    $( '#end-message' ).hide()

    $.ajax {
      type: 'GET'
      url: $( '#screen-assignment-json-url' ).text()
      success:
        ( data ) ->
          start_screening( data.citations_projects ) 
    }
  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->
