
document.addEventListener 'turbolinks:load', ->
  do ->
    loyloy = ( obj, data ) ->
      console.log('loyloy')
      return

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

    #gets the first citation from citations and updates indes with it
    next_citation = ( obj ) ->
      if obj.citations.length == 0
        return
      obj.history.unshift obj.citations.shift()
      return

    update_info = ( obj ) ->
      current_citation = obj.history[ obj.index ]

      $( '#citation-name' ).text( current_citation.name )
      $( '#citation-abstract' ).text( current_citation.abstract )
      $( '#citation-pmid' ).text( current_citation.pmid )
      $( '#citation-refman' ).text( current_citation.refman )
      $( '#journal-name' ).text( current_citation.journal.name )
      $( '#journal-date' ).text( current_citation.journal.publication_date )

      $( '#citation-authors' ).empty()
      for a in current_citation.authors
        author = document.createElement( 'li' )
        author.innerHTML = a.name
        $( '#citation-authors' ).append( author )

      $( '#citation-keywords' ).empty()
      for k in current_citation.keywords
        keyword = document.createElement( 'li' )
        keyword.innerHTML = k.name
        $( '#citation-keywords' ).append( keyword )

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

    send_label = ( obj, label_value ) ->
      this.current_citation = obj.history[ obj.index ]
      # check if 'create' label or 'update'
      # if 'update', append label id
      label_url = $( '#labels-url' ).text()
      if obj.index > 0
        label_url = label_url + '/' + obj.history[ obj.index ].label_id
      $.ajax {
        type: if obj.index > 0 then 'PATCH' else 'POST'
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
      }  
      return

    label_action = ( obj, label_value ) -> 
      send_label( obj, label_value )
      get_c_p( obj )
# see trello card
      if obj.index > 0
        obj.index = 0
      else
        next_citation( obj )
      update_info( obj )
      update_arrows( obj )
      return
      
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

    start_screening = ( citations ) ->
      # session state is stored in state_obj, and this object is passed in methods that modify the state
      state_obj = { citations: citations, history: [ ], index: 0 }
      next_citation( state_obj )
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

      $( '#next-button' ).click ->
        state_obj.index--
        update_arrows( state_obj )
        update_info( state_obj )

      $( '#previous-button' ).click ->
        state_obj.index++
        update_arrows( state_obj )
        update_info( state_obj )
      return

    #$( '#hide-me' ).hide()

    $.ajax {
      type: 'GET'
      url: $( '#screen-assignment-json-url' ).text()
      success:
        ( data ) ->
          start_screening( data.citations_projects ) 
    }
  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->


