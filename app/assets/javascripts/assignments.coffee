# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  do ->
    c_p_data = null

    $.ajax( {
      async: false,
      type: 'GET',
      url: $( '#screen-assignment-json-url' ).text(),
      success: ( data ) ->
        c_p_data = data
    } ) 

    console.log(c_p_data)

    $( '#hide-me' ).hide()

    $( '#yes-button' ).click ->
      $( "#label-input[value='yes']" ).prop( 'checked', true )

      label_json = { label: { value: 'yes', citations_project_id: c_p_data.citations_projects[0].id } }
      #label_json = "{ 'label': { 'value': 'yes' , 'citations_project_id': " + c_p_data.citations_projects[0].id + " } }"
      
      $.ajax( {
        type: 'POST',
        url: $( '#citations-url' ).text(),
        dataType: 'json',
        data: label_json,
        success: ( response ) ->
          console.log( response )
      } )

      return 

    $( '#maybe-button' ).click ->
      $( "#label-input[value='maybe']" ).prop( 'checked', true )
      $("#label-form").submit();
      return

    $( '#no-button' ).click ->
      $( "#label-input[value='no']" ).prop( 'checked', true )
      $("#label-form").submit();
      return

  return # END do ->

return # END document.addEventListener 'turbolinks:load', -> 
