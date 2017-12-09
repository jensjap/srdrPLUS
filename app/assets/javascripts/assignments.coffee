# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
loyloy = ->
  console.log('loyloy')
  return

#get a list of unlabeled_citations from server
get_c_p = ( obj, async ) ->
  if obj.citations_projects.length < 5
    c_p_json = { }
    c_p_json[ 'async' ]   = async
    c_p_json[ 'type' ]    = 'GET'
    c_p_json[ 'url' ]     = $( '#screen-assignment-json-url' ).text()
    c_p_json[ 'success' ] = ( data ) -> ( obj.citations_projects = data.citations_projects )

    $.ajax( c_p_json )
  return

#gets the first citation from citations_projects and updates current_citation with it
next_citation = ( obj ) ->
  if obj.current_citation.length == 0
    return
  obj.current_citation = obj.citations_projects.shift()
  $( '#citation-name' ).text( obj.current_citation.name )
  $( '#citation-abstract' ).text( obj.current_citation.abstract )
  $( '#citation-pmid' ).text( obj.current_citation.pmid )
  $( '#citation-refman' ).text( obj.current_citation.refman )

  $( '#citation-authors' ).empty()
  for a in obj.current_citation.authors
    author = document.createElement('li')
    author.innerHTML = a.name
    $( '#citation-authors' ).append(author)

  $( '#citation-keywords' ).empty()
  for k in obj.current_citation.keywords
    keyword = document.createElement('li')
    keyword.innerHTML = k.name
    $( '#citation-keywords' ).append(keyword)
  return

send_label = ( c_p_id, label_value ) ->
  label_json = { }
  label_json[ 'utf8' ]                = '✓'
  label_json[ 'authenticity_token' ]  = $( '#authenticity-token' ).text()
  label_json[ 'label' ]               = { value: label_value, citations_project_id: c_p_id }

  data_json = { }
  data_json[ 'type' ]                 = 'POST'
  data_json[ 'url' ]                  = $( '#citations-url' ).text()
  data_json[ 'dataType' ]             = 'json'
  data_json[ 'data' ]                 = label_json
  data_json[ 'success' ]              = loyloy()

  $.ajax( data_json )
  return

document.addEventListener 'turbolinks:load', ->
  do ->
    $( '#hide-me' ).hide()

    # get citations_project data from server
    screen_obj = { citations_projects: [ ], current_citation: {} }
    get_c_p( screen_obj, false )
    console.log( screen_obj )
    next_citation( screen_obj )

    $( '#yes-button' ).click ->
      $( "#label-input[value='yes']" ).prop( 'checked', true )
      send_label( screen_obj.current_citation.id,'yes' )
      get_c_p( screen_obj, true )
      next_citation( screen_obj )


    $( '#maybe-button' ).click ->
      $( "#label-input[value='maybe']" ).prop( 'checked', true )
      send_label( screen_obj.current_citation.id,'maybe' )
      get_c_p( screen_obj, true )
      next_citation( screen_obj )

    $( '#no-button' ).click ->
      $( "#label-input[value='no']" ).prop( 'checked', true )
      send_label( screen_obj.current_citation.id,'no' )
      get_c_p( screen_obj, true )
      next_citation( screen_obj )

  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->


