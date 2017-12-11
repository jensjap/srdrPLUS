loyloy = ( obj, data ) ->
  console.log('loyloy')
  return

#get a list of unlabeled_citations from server
get_c_p = ( obj ) ->
  if obj.citations.length < 5
    request_json          = { }
    request_json.type     = 'GET'
    request_json.url      = $( '#screen-assignment-json-url' ).text()
    request_json.success  = ( data ) -> ( obj.citations = data.citations_projects; console.log( data ) )

    $.ajax( request_json )
  return

#gets the first citation from citations and updates indes with it
next_citation = ( obj ) ->
  if obj.citations.length == 0
    return

  obj.history.unshift( obj.citations.shift() )
  return

update_info = ( obj ) ->
  console.log ( obj.index ) 
  current_citation = obj.history[ obj.index ]

  $( '#citation-name' ).text( current_citation.name )
  $( '#citation-abstract' ).text( current_citation.abstract )
  $( '#citation-pmid' ).text( current_citation.pmid )
  $( '#citation-refman' ).text( current_citation.refman )

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
  return

send_label = ( obj, label_value ) ->
  this.current_citation = obj.history[ obj.index ]
  # check if 'create' label or 'update'
  # if 'update', append label id
  label_url = $( '#labels-url' ).text()
  if obj.index > 0
    label_url = label_url + '/' + obj.history[ obj.index ].label_id
    console.log label_url

  label_json = { }
  label_json.utf8                 = '✓'
  label_json.authenticity_token   = $( '#authenticity-token' ).text()
  label_json.label                = { value: label_value, citations_project_id: current_citation.id }

  data_json = { }
  # if 'update', use 'PATCH' request
  if obj.index > 0
    data_json.type                  = 'PATCH'
  else
    data_json.type                  = 'POST'
  data_json.url                   = label_url
  data_json.dataType              = 'json'
  data_json.data                  = label_json
  data_json.success               = ( data ) -> ( parent.current_citation.label_id = data.id )

  $.ajax( data_json )
  return

label_action = ( obj, label_value ) -> 
  send_label( obj, label_value )
  get_c_p( obj )
  if obj.index > 0
    obj.index = 0
  else
    next_citation( obj )
  update_info( obj )
  update_arrows( obj )
  return
  
update_arrows = ( obj ) ->
  if obj.index < obj.history.length - 1
    $( '#previous-button' ).show()
  else
    $( '#previous-button' ).hide()

  if obj.index > 0
    $( '#next-button' ).show()
  else
    $( '#next-button' ).hide()
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

document.addEventListener 'turbolinks:load', ->
  do ->
    $( '#hide-me' ).hide()

    request_json          = { }
    request_json.type     = 'GET'
    request_json.url      = $( '#screen-assignment-json-url' ).text()
    request_json.success  = ( data ) -> ( start_screening( data.citations_projects ) )
    $.ajax( request_json )
  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->


