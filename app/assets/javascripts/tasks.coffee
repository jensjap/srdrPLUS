document.addEventListener 'turbolinks:load', ->
  do ->

    $('.task_num_assigned').hide()

    $('#task_task_type_id').on "change", ->
      if ($('#task_task_type_id option:selected').text() != "Advanced")
        $('.task_num_assigned').hide()
      else
        $('.task_num_assigned').show()
        $('#task_num_assigned').val('')
