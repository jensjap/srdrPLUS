# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
loyloy = ->
  console.log('loyloy')
  return

get_c_p = ( obj, async ) ->
  if obj.data.citations_projects.length < 5
    c_p_json = { }
    c_p_json[ 'async' ]   = async
    c_p_json[ 'type' ]    = 'GET'
    c_p_json[ 'url' ]     = $( '#screen-assignment-json-url' ).text()
    c_p_json[ 'success' ] = ( data ) -> ( obj.data = data )

    $.ajax( c_p_json )

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
    #$( '#hide-me' ).hide()

    # get citations_project data from server
    c_p_obj = { data: { citations_projects: [] } }
    get_c_p( c_p_obj, true )

    console.log( c_p_obj )

    $( '#yes-button' ).click ->
      $( "#label-input[value='yes']" ).prop( 'checked', true )
      send_label( c_p_obj.data.citations_projects.shift().id,'yes' )
      get_c_p( c_p_obj, false )

    $( '#maybe-button' ).click ->
      $( "#label-input[value='maybe']" ).prop( 'checked', true )
      send_label( c_p_obj.data.citations_projects.shift().id,'maybe' )
      get_c_p( c_p_obj, false )

    $( '#no-button' ).click ->
      $( "#label-input[value='no']" ).prop( 'checked', true )
      send_label( c_p_obj.data.citations_projects.shift().id,'no' )
      get_c_p( c_p_obj, false )

  return # END do ->
return # END document.addEventListener 'turbolinks:load', ->


