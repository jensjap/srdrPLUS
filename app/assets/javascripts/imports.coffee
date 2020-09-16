document.addEventListener 'turbolinks:load', ->
  do ->
    types_columns_dict = { "Arm Details": [ "Arm Name",\
                                            "Arm Description",\
                                            "CitationId",\
                                            "Included",\
                                            "Refman",\
                                            "Pmid",\
                                            "UserAssigned",\
                                            "StudyTitle",\
                                            "PublicationDate",\
                                            "Author" ],\
                            "Design Details": [ "CitationId",\
                                                "Included",\
                                                "Refman",\
                                                "Pmid",\
                                                "UserAssigned",\
                                                "StudyTitle",\
                                                "PublicationDate",\
                                                "Author" ],\
                            "Study Results": [  "CitationId",\
                                          "Included",\
                                          "Refman",\
                                          "Pmid" ] }
 
    current_mapping = {}
    current_sheet_name_mapping = {}
    workbook = undefined
    filedata = undefined

    if $( '.imports.new' ).length > 0
      #### FILE DROPZONE
      Dropzone.options.fileDropzone = {
        url: $('#fileDropzone').attr('dropzone-path'),
        autoProcessQueue: false,
        uploadMultiple: false,
        maxFiles: 1,

        init: ()->
          wrapperThis = this
          this.on('addedfile', (file) ->
            filedata = file
            $('#import-columns-panel').html ''
            $('#import-tabs-panel').html ''
            reader = new FileReader()
            reader.onload = (e) ->
              data = new Uint8Array(e.target.result);
              workbook = XLSX.read(data, {type: 'array'})
              cur_index = 0
              for sheet_name, ws of workbook['Sheets']
                current_row_elem = add_row( sheet_name )
                current_row_elem.attr 'id', 'sheet-row-' + cur_index
                header = []
                columnCount = XLSX.utils.decode_range(ws['!ref']).e.c
                for i in [0..columnCount]
                  col_let = XLSX.utils.encode_col(i)
                  h = ws[col_let + "1"]
                  if h != undefined
                    header[i] = h.v
                    add_header( current_row_elem, h.v )
                  else
                    # WHAT TO DO WITH EMPTY HEADERS
                    header[i] = undefined
                    add_header( current_row_elem, "" )
                current_type_select = $( current_row_elem ).find( '.section-type-select' )
                select_closest_type( sheet_name, current_type_select )
                add_srdr_headers( $( current_type_select ).find('option:selected').text(), current_row_elem )
                apply_droppable( current_row_elem )
                cur_index += 1
            reader.readAsArrayBuffer(filedata)
            this.removeFile(file)
            $('#import-panel-container').removeClass 'hide'
            $('#dropzone-div').addClass 'hide'
          )
      }

      new Dropzone( '#fileDropzone' )

      $('.create-button').on('click', () -> 
        fd = new FormData()
        fd.append("content", update_file_headers())
        fd.append("projects_user_id", $("#dropzone-div input[name='import[projects_user_id]']").val())
        fd.append("import_type_id", $("#dropzone-div input[name='import[import_type_id]']").val())
        fd.append("file_type_id", $("#dropzone-div input[name='import[file_type_id]']").val())
        fd.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val())

        $.ajax({ 
          url: $('#fileDropzone').attr('dropzone-path'),
          method: 'post',
          data: fd,
          processData: false,
          contentType: false,
          success: () ->
            toastr.success('Excel file successfully uploaded. You will be notified by email when citaion import finishes.')
            filedata = undefined
            reset_state()
          ,
          error: () ->
            toastr.error('ERROR: Cannot upload Excel file.')
        })
      )

      $('.discard-button').on('click', () ->
        reset_state()
      )

    reset_state = () ->
      $('#import-panel-container').addClass 'hide'
      $('#dropzone-div').removeClass 'hide'
      current_mapping = {}
      workbook = undefined
      filedata = undefined
      $('#import-columns-panel').html ''
      $('#import-tabs-panel').html ''
      
    add_header = ( row_elem, header_name ) ->
      cutoff_limit = 160
      short_header_name = header_name
      if header_name.length > cutoff_limit
        short_header_name = header_name.slice(0,cutoff_limit) + "..."
      new_header_elem = $( '<div></div>' ).text( short_header_name ).addClass( 'header-column' ).attr( 'full-header', header_name )
      $( row_elem ).find( '.bottom' ).append( new_header_elem )
      return new_header_elem

    add_row = ( sheet_name ) ->
      new_row_elem = $( '<div></div>' ).addClass( 'import-columns-row' )
      type_select = $('<select></select>').addClass( 'section-type-select' )
      for type_name, type_columns of types_columns_dict #needs revision
        if ( XLSX.utils.decode_range(workbook['Sheets'][sheet_name]['!ref']).e.c >= types_columns_dict[type_name].length)
          type_option = $( '<option></option>' ).text( type_name )
          type_select.append( type_option )

      type_select.on 'change', () ->
        add_srdr_headers( $(this).find('option:selected').text(), new_row_elem )
        current_sheet_name_mapping[sheet_name] = $(this).find('option:selected').text()

      new_row_elem.append( $('<div></div>').addClass( 'sheet-name' ).append( $('<span></span>').text( sheet_name ).addClass('hide') ).append( type_select ) )
      headers_elem = $('<div></div>').addClass( 'headers' )
      headers_elem.append( $('<div></div>').addClass( 'top' ) )
      headers_elem.append( $('<div></div>').addClass( 'bottom' ) )
      new_row_elem.append( headers_elem )
      $( '#import-columns-panel' ).append( new_row_elem )

      new_tab_elem = $( '<div></div>' ).addClass( 'import-columns-tab' ).attr('sheet-name',sheet_name).text(sheet_name)
      if $( '.import-columns-tab' ).length == 0
        new_tab_elem.addClass 'selected'
        new_tab_elem.on 'click', () ->
          $( '#import-columns-panel' ).css( 'border-radius', '0 1rem 1rem 1rem' )
          $( '.import-columns-row' ).addClass 'hide'
          new_row_elem.removeClass 'hide'
          $( '.import-columns-tab.selected' ).removeClass 'selected' 
          new_tab_elem.addClass 'selected'
      else
        new_row_elem.addClass 'hide'
        new_tab_elem.on 'click', () ->
          $( '#import-columns-panel' ).css( 'border-radius', '1rem' )
          $( '.import-columns-row' ).addClass 'hide'
          new_row_elem.removeClass 'hide'
          $( '.import-columns-tab.selected' ).removeClass 'selected' 
          new_tab_elem.addClass 'selected'

      $( '#import-tabs-panel' ).append( new_tab_elem )
      current_mapping[sheet_name] = {}
      return new_row_elem

    add_srdr_headers = ( type_name, row_elem ) ->
      headers_to_add = types_columns_dict[type_name].map((x) -> x)
      sheet_name = get_sheet_name(row_elem)
      current_mapping[sheet_name] = {}
      cur_index = 0

      if $( row_elem ).find( '.header-column' ).length < headers_to_add.length
        alert("There are fewer Excel columns than what is required for this type of section.")
        return

      $( row_elem ).find( '.top' ).html('')
      for import_column in [0..$( row_elem ).find( '.header-column' ).length]
        $( row_elem ).find( '.top' ).append( $( '<div></div>' ).addClass( 'import-column' ).attr('index', cur_index) ) 
        cur_index += 1

      while headers_to_add.length > 0
        srdr_header = headers_to_add.pop(0)
        min_edit_distance = Number.POSITIVE_INFINITY
        min_index = 0 
        cur_index = 0
        for import_column in $( row_elem ).find( '.header-column' )
          header_text = $( import_column ).attr( 'full-header' )
          cur_edit_distance = Levenshtein.get( srdr_header, header_text )
          $cur_dropzone = $( row_elem ).find( '.top' ).find( '.import-column[index="' + cur_index + '"]')
          if cur_edit_distance < min_edit_distance
            if $cur_dropzone.hasClass('draggable-dropzone--occupied')
              existing_srdr_header = $cur_dropzone.find('.is-droppable').first().text()
              if Levenshtein.get( srdr_header, header_text ) < Levenshtein.get( existing_srdr_header, header_text )
                min_index = cur_index
                min_edit_distance = cur_edit_distance
                headers_to_add.push(existing_srdr_header)
                $cur_dropzone.html('')
                $cur_dropzone.removeClass('draggable-dropzone--occupied')
              else
                ##  ?????
            else
              min_index = cur_index
              min_edit_distance = cur_edit_distance
          cur_index += 1
        $( row_elem ).find( '.top' ).find( '.import-column[index="' + min_index + '"]').addClass('draggable-dropzone--occupied').append($('<div></div>').addClass('is-droppable').text( srdr_header ))
        current_mapping[sheet_name][srdr_header] = "" + min_index
      return row_elem

    select_closest_type = ( sheet_name, select_elem ) ->
      min_index = 0
      cur_index = 0
      min_edit_distance = Number.POSITIVE_INFINITY
      type_names = Object.keys(types_columns_dict)
      for type_name in type_names
        if $( select_elem ).parents('.import-columns-row').find( '.header-column' ).length >= types_columns_dict[type_name].length
          cur_edit_distance = Levenshtein.get( sheet_name, type_name )
          if (cur_edit_distance < min_edit_distance)
            min_index = cur_index
            min_edit_distance = cur_edit_distance
          cur_index += 1

      current_sheet_name_mapping[sheet_name] = type_names[min_index]
      $( select_elem ).find( 'option:contains("' + type_names[min_index] + '")').prop('selected', true)

    apply_droppable = ( row_elem ) ->
      droppable = new Droppable.default( $( row_elem ).find( '.headers .top' ).toArray(), { draggable: '.is-droppable', dropzone: '#' + $( row_elem ).attr( 'id' ) + ' .headers .top .import-column', plugins: [] })

      sheet_name = get_sheet_name ( row_elem )
      droppable.on 'droppable:stop', (evt) ->
        srdr_header = $( evt.dropzone ).find( '.is-droppable' ).text()
        current_mapping[sheet_name][srdr_header] = $( evt.dropzone ).attr( 'index' )

    get_sheet_name = ( row_elem ) -> return $(row_elem).find('.sheet-name span').text()

    update_file_headers = () ->
      if workbook != undefined
        console.log workbook
        i = 0
        sheet_name_d = {}
        for sheet_name, sheet_dict of current_mapping
          ws = workbook['Sheets'][sheet_name]
          console.log current_sheet_name_mapping[sheet_name]
          if current_sheet_name_mapping[sheet_name] of sheet_name_d
            current_sheet_name_mapping[sheet_name] = current_sheet_name_mapping[sheet_name] + ' ' + sheet_name_d[current_sheet_name_mapping[sheet_name]]
            sheet_name_d[current_sheet_name_mapping[sheet_name]] += 1
          else
            sheet_name_d[current_sheet_name_mapping[sheet_name]] = 2
          workbook['SheetNames'][''+i] = current_sheet_name_mapping[sheet_name]
          for srdr_header, index of sheet_dict
            ws[XLSX.utils.encode_col(index) + "1"].t = 's'
            ws[XLSX.utils.encode_col(index) + "1"].v = srdr_header
            ws[XLSX.utils.encode_col(index) + "1"].w = undefined
          i+=1

        console.log workbook
        #if confirm("Do you want to download fixed file?")
        XLSX.writeFile(workbook, "fixed_" + filedata.name)
        b = new Blob([s2ab(XLSX.write(workbook, {bookType:'xlsx', type:'binary'}))], { type: "application/octet-stream"})
        return new File([b], filedata.name)
      else
        return undefined
        console.log 'workbook not set'

    s2ab = (s) ->
      buf = new ArrayBuffer(s.length)
      #convert s to arrayBuffer
      view = new Uint8Array(buf)
      #create uint8array as viewer
      i = 0
      while i < s.length
        view[i] = s.charCodeAt(i) & 0xFF
        i++
      #convert to octet
      buf
