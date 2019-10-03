document.addEventListener 'turbolinks:load', ->

  return unless $( '.tasks' ).length > 0

  do ->

    $( '.task_num_assigned' ).hide()

    $( '#task_task_type_id' ).on "change", ->
      if ( $( '#task_task_type_id option:selected' ).text() != "Advanced" )
        $( '.task_num_assigned' ).hide()
      else
        $( '.task_num_assigned' ).show()
        $( '#task_num_assigned' ).val('')

    return # END do ->

  return # END turbolinks:load
