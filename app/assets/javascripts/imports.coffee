document.addEventListener 'turbolinks:load', ->
  do ->
    types_columns_dict = { "Type 1": ["a", "b", "c"],\
                            "Type 2": ["d","e"],\
                            "Results": ["f", "g", "h", "hh"] }

    current_mapping = {}

    if $( '.imports.new' ).length > 0
      $( 'input[type="file"]' ).on 'change', () ->
        $('#import-columns-panel').html ''
        filedata = $(this)[0].files[0]
        #workbook = XLSX.read(filedata)
        reader = new FileReader()
        reader.onload = (e) ->
          data = new Uint8Array(e.target.result);
          workbook = XLSX.read(data, {type: 'array'})
          cur_index = 0
          for sheet_name, ws of workbook['Sheets']
            current_row_elem = add_row( sheet_name )
            current_row_elem.attr 'id', 'sheet-row-' + cur_index
            header = []
            columnCount = XLSX.utils.decode_range(ws['!ref']).e.c + 1
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
        reader.readAsArrayBuffer(filedata);
      
    add_header = ( row_elem, header_name ) ->
      cutoff_limit = 14
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
        type_option = $( '<option></option>' ).text( type_name )
        type_select.append( type_option )

      type_select.on 'change', () ->
        add_srdr_headers( $(this).find('option:selected').text(), new_row_elem )

      new_row_elem.append( $('<div></div>').addClass( 'sheet-name' ).text( sheet_name ).append( type_select ) )
      headers_elem = $('<div></div>').addClass( 'headers' )
      headers_elem.append( $('<div></div>').addClass( 'top' ) )
      headers_elem.append( $('<div></div>').addClass( 'bottom' ) )
      new_row_elem.append( headers_elem )
      $( '#import-columns-panel' ).append( new_row_elem )
      current_mapping[sheet_name] = {}
      return new_row_elem

    add_srdr_headers = ( type_name, row_elem ) ->
      headers_to_add = types_columns_dict[type_name]
      sheet_name = $(row_elem).find('sheet-name').text()
      current_mapping[sheet_name] = {}
      cur_index = 0

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
              existing_srdr_header = $cur_dropzone.find('.is-droppable').text()
              if Levenshtein.get( srdr_header, header_text ) < Levenshtein.get( existing_srdr_header, header_text )
                min_index = cur_index
                min_edit_distance = cur_edit_distance
                headers_to_add.push(existing_srdr_header)
                $cur_dropzone.html('')
                $cur_dropzone.removeClass('draggable-dropzone--occupied')
              else


            else
              min_index = cur_index
              min_edit_distance = cur_edit_distance
          cur_index += 1
        $( row_elem ).find( '.top' ).find( '.import-column[index="' + min_index + '"]').addClass('draggable-dropzone--occupied').append($('<div></div>').addClass('is-droppable').text( srdr_header ))
        current_mapping[sheet_name][srdr_header] = min_index
      return row_elem

    select_closest_type = ( sheet_name, select_elem ) ->
      min_index = 0
      cur_index = 0
      min_edit_distance = Number.POSITIVE_INFINITY
      type_names = Object.keys(types_columns_dict)
      for type_name in type_names
        cur_edit_distance = Levenshtein.get( sheet_name, type_name )
        if cur_edit_distance < min_edit_distance
          min_index = cur_index
          min_edit_distance = cur_edit_distance
        cur_index += 1

      $( select_elem ).find( 'option:contains("' + type_names[min_index] + '")').prop('selected', true)

    apply_droppable = ( row_elem ) ->
      droppable = new Droppable.default( $( row_elem ).find( '.headers .top' ).toArray(), { draggable: '.is-droppable', dropzone: '#' + $( row_elem ).attr( 'id' ) + ' .headers .top .import-column', plugins: [] })