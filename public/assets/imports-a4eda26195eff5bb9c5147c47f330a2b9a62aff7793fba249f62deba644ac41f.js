(function() {
  document.addEventListener('DOMContentLoaded', function() {
    return (function() {
      var add_header, add_row, add_srdr_headers, apply_droppable, current_mapping, current_sheet_name_mapping, filedata, get_sheet_name, reset_state, s2ab, select_closest_type, types_columns_dict, update_file_headers, workbook;
      types_columns_dict = {
        "Arm Details": ["Arm Name", "Arm Description", "CitationId", "Included", "Refman", "Pmid", "UserAssigned", "StudyTitle", "PublicationDate", "Author"],
        "Design Details": ["CitationId", "Included", "Refman", "Pmid", "UserAssigned", "StudyTitle", "PublicationDate", "Author"],
        "Study Results": ["CitationId", "Included", "Refman", "Pmid"]
      };
      current_mapping = {};
      current_sheet_name_mapping = {};
      workbook = void 0;
      filedata = void 0;
      if ($('.imports.new').length > 0) {
        Dropzone.options.fileDropzone = {
          url: $('#fileDropzone').attr('dropzone-path'),
          autoProcessQueue: false,
          uploadMultiple: false,
          maxFiles: 1,
          init: function() {
            var wrapperThis;
            wrapperThis = this;
            return this.on('addedfile', function(file) {
              var reader;
              filedata = file;
              $('#import-columns-panel').html('');
              $('#import-tabs-panel').html('');
              reader = new FileReader();
              reader.onload = function(e) {
                var col_let, columnCount, cur_index, current_row_elem, current_type_select, data, h, header, i, j, palette_elem, ref, ref1, ref2, results, sheet_name, ws;
                data = new Uint8Array(e.target.result);
                workbook = XLSX.read(data, {
                  type: 'array'
                });
                cur_index = 0;
                ref = workbook['Sheets'];
                results = [];
                for (sheet_name in ref) {
                  ws = ref[sheet_name];
                  ref1 = add_row(sheet_name), current_row_elem = ref1[0], palette_elem = ref1[1];
                  current_row_elem.attr('id', 'sheet-row-' + cur_index);
                  header = [];
                  columnCount = XLSX.utils.decode_range(ws['!ref']).e.c;
                  for (i = j = 0, ref2 = columnCount; 0 <= ref2 ? j <= ref2 : j >= ref2; i = 0 <= ref2 ? ++j : --j) {
                    col_let = XLSX.utils.encode_col(i);
                    h = ws[col_let + "1"];
                    if (h !== void 0) {
                      header[i] = h.v;
                      add_header(current_row_elem, h.v);
                    } else {
                      header[i] = void 0;
                      add_header(current_row_elem, "");
                    }
                  }
                  current_type_select = $(current_row_elem).find('.section-type-select');
                  select_closest_type(sheet_name, current_type_select);
                  add_srdr_headers($(current_type_select).find('option:selected').text(), current_row_elem, palette_elem);
                  apply_droppable(current_row_elem, palette_elem);
                  results.push(cur_index += 1);
                }
                return results;
              };
              reader.readAsArrayBuffer(filedata);
              this.removeFile(file);
              $('#import-panel-container').removeClass('hide');
              return $('#dropzone-div').addClass('hide');
            });
          }
        };
        new Dropzone('#fileDropzone');
        $('.create-button').on('click', function() {
          var fd;
          fd = new FormData();
          fd.append("content", update_file_headers());
          fd.append("projects_user_id", $("#dropzone-div input[name='import[projects_user_id]']").val());
          fd.append("import_type_id", $("#dropzone-div input[name='import[import_type_id]']").val());
          fd.append("file_type_id", $("#dropzone-div input[name='import[file_type_id]']").val());
          fd.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val());
          return $.ajax({
            url: $('#fileDropzone').attr('dropzone-path'),
            method: 'post',
            data: fd,
            processData: false,
            contentType: false,
            success: function() {
              toastr.success('Excel file successfully uploaded. You will be notified by email when citation import finishes.');
              filedata = void 0;
              return reset_state();
            },
            error: function() {
              return toastr.error('ERROR: Cannot upload Excel file.');
            }
          });
        });
        $('.discard-button').on('click', function() {
          return reset_state();
        });
      }
      reset_state = function() {
        $('#import-panel-container').addClass('hide');
        $('#dropzone-div').removeClass('hide');
        current_mapping = {};
        workbook = void 0;
        filedata = void 0;
        $('#import-columns-panel').html('');
        return $('#import-tabs-panel').html('');
      };
      add_header = function(row_elem, header_name) {
        var cutoff_limit, new_header_elem, short_header_name;
        cutoff_limit = 160;
        short_header_name = header_name;
        if (header_name.length > cutoff_limit) {
          short_header_name = header_name.slice(0, cutoff_limit) + "...";
        }
        new_header_elem = $('<div></div>').text(short_header_name).addClass('header-column').attr('full-header', header_name);
        $(row_elem).find('.bottom').append(new_header_elem);
        return new_header_elem;
      };
      add_row = function(sheet_name) {
        var headers_elem, new_row_elem, new_tab_elem, palette_elem, type_columns, type_name, type_option, type_select;
        palette_elem = $('<div></div>').addClass('palette');
        $('#palette-container').append(palette_elem);
        new_row_elem = $('<div></div>').addClass('import-columns-row');
        type_select = $('<select></select>').addClass('section-type-select');
        for (type_name in types_columns_dict) {
          type_columns = types_columns_dict[type_name];
          if (XLSX.utils.decode_range(workbook['Sheets'][sheet_name]['!ref']).e.c >= types_columns_dict[type_name].length) {
            type_option = $('<option></option>').text(type_name);
            type_select.append(type_option);
          }
        }
        type_select.on('change', function() {
          add_srdr_headers($(this).find('option:selected').text(), new_row_elem, palette_elem);
          return current_sheet_name_mapping[sheet_name] = $(this).find('option:selected').text();
        });
        new_row_elem.append($('<div></div>').addClass('sheet-name').append($('<span></span>').text(sheet_name).addClass('hide')).append(type_select));
        headers_elem = $('<div></div>').addClass('headers');
        headers_elem.append($('<div></div>').addClass('top'));
        headers_elem.append($('<div></div>').addClass('bottom'));
        new_row_elem.append(headers_elem);
        $('#import-columns-panel').append(new_row_elem);
        new_tab_elem = $('<div></div>').addClass('import-columns-tab').attr('sheet-name', sheet_name).text(sheet_name);
        if ($('.import-columns-tab').length === 0) {
          new_tab_elem.addClass('selected');
          new_tab_elem.on('click', function() {
            $('#import-columns-panel').css('border-radius', '0 1rem 1rem 1rem');
            $('.import-columns-row').addClass('hide');
            $('.palette').addClass('hide');
            new_row_elem.removeClass('hide');
            palette_elem.removeClass('hide');
            $('.import-columns-tab.selected').removeClass('selected');
            return new_tab_elem.addClass('selected');
          });
        } else {
          palette_elem.addClass('hide');
          new_row_elem.addClass('hide');
          new_tab_elem.on('click', function() {
            $('#import-columns-panel').css('border-radius', '1rem');
            $('.import-columns-row').addClass('hide');
            $('.palette').addClass('hide');
            new_row_elem.removeClass('hide');
            palette_elem.removeClass('hide');
            $('.import-columns-tab.selected').removeClass('selected');
            return new_tab_elem.addClass('selected');
          });
        }
        $('#import-tabs-panel').append(new_tab_elem);
        current_mapping[sheet_name] = {};
        return [new_row_elem, palette_elem];
      };
      add_srdr_headers = function(type_name, row_elem, palette_elem) {
        var $cur_dropzone, cur_edit_distance, cur_index, droppable_elem, existing_srdr_header, header_text, headers_to_add, import_column, j, k, len, min_edit_distance, min_index, ref, ref1, sheet_name, srdr_header;
        headers_to_add = types_columns_dict[type_name].map(function(x) {
          return x;
        });
        sheet_name = get_sheet_name(row_elem);
        current_mapping[sheet_name] = {};
        cur_index = 0;
        if ($(row_elem).find('.header-column').length < headers_to_add.length) {
          alert("There are fewer Excel columns than what is required for this type of section.");
          return;
        }
        $(palette_elem).html('');
        $(row_elem).find('.top').html('');
        for (import_column = j = 0, ref = $(row_elem).find('.header-column').length - 1; 0 <= ref ? j <= ref : j >= ref; import_column = 0 <= ref ? ++j : --j) {
          $(row_elem).find('.top').append($('<div></div>').addClass('import-column').attr('index', cur_index));
          cur_index += 1;
        }
        while (headers_to_add.length > 0) {
          srdr_header = headers_to_add.pop(0);
          $(palette_elem).append($('<div></div>').addClass('import-column').attr('srdr-header', srdr_header).append($('<span></span>').text(srdr_header)));
          min_edit_distance = Number.POSITIVE_INFINITY;
          min_index = 0;
          cur_index = 0;
          ref1 = $(row_elem).find('.header-column');
          for (k = 0, len = ref1.length; k < len; k++) {
            import_column = ref1[k];
            header_text = $(import_column).attr('full-header');
            cur_edit_distance = Levenshtein.get(srdr_header, header_text);
            $cur_dropzone = $(row_elem).find('.top').find('.import-column[index="' + cur_index + '"]');
            if (cur_edit_distance < min_edit_distance) {
              if ($cur_dropzone.hasClass('draggable-dropzone--occupied')) {
                existing_srdr_header = $cur_dropzone.find('.is-droppable').first().text();
                if (Levenshtein.get(srdr_header, header_text) < Levenshtein.get(existing_srdr_header, header_text)) {
                  min_index = cur_index;
                  min_edit_distance = cur_edit_distance;
                  headers_to_add.push(existing_srdr_header);
                  $cur_dropzone.html('');
                  $cur_dropzone.removeClass('draggable-dropzone--occupied');
                } else {

                }
              } else {
                min_index = cur_index;
                min_edit_distance = cur_edit_distance;
              }
            }
            cur_index += 1;
          }
          droppable_elem = $('<div></div>').addClass('is-droppable').text(srdr_header);
          $(row_elem).find('.top').find('.import-column[index="' + min_index + '"]').addClass('draggable-dropzone--occupied').append(droppable_elem);
          droppable_elem.dblclick(function() {
            var $this, target_elem;
            $this = $(this);
            $this.parent().removeClass('draggable-dropzone--occupied');
            $this.detach();
            target_elem = $(palette_elem).find('.import-column[srdr-header="' + $this.text() + '"]');
            target_elem.append($this);
            return target_elem.addClass('draggable-dropzone--occupied');
          });
          current_mapping[sheet_name][srdr_header] = "" + min_index;
        }
        return row_elem;
      };
      select_closest_type = function(sheet_name, select_elem) {
        var cur_edit_distance, cur_index, j, len, min_edit_distance, min_index, type_name, type_names;
        min_index = 0;
        cur_index = 0;
        min_edit_distance = Number.POSITIVE_INFINITY;
        type_names = Object.keys(types_columns_dict);
        for (j = 0, len = type_names.length; j < len; j++) {
          type_name = type_names[j];
          if ($(select_elem).parents('.import-columns-row').find('.header-column').length >= types_columns_dict[type_name].length) {
            cur_edit_distance = Levenshtein.get(sheet_name, type_name);
            if (cur_edit_distance < min_edit_distance) {
              min_index = cur_index;
              min_edit_distance = cur_edit_distance;
            }
            cur_index += 1;
          }
        }
        current_sheet_name_mapping[sheet_name] = type_names[min_index];
        return $(select_elem).find('option:contains("' + type_names[min_index] + '")').prop('selected', true);
      };
      apply_droppable = function(row_elem, palette_elem) {
        var droppable, sheet_name;
        droppable = new Draggable.Droppable($(row_elem).find('.headers .top').toArray().concat(palette_elem.toArray()), {
          draggable: '.is-droppable',
          dropzone: '#' + $(row_elem).attr('id') + ' .headers .top .import-column, #palette-container .palette .import-column',
          plugins: []
        });
        sheet_name = get_sheet_name(row_elem);
        return droppable.on('droppable:stop', function(evt) {
          var origin_elem, srdr_header, target_elem;
          srdr_header = $(evt.dropzone).find('.is-droppable').text();
          target_elem = $(palette_elem).find('.import-column[srdr-header="' + srdr_header + '"]');
          origin_elem = $(evt.dragEvent.originalSource);
          if ($(evt.dropzone).parents('.palette').length > 0 && origin_elem.parents('.palette').length === 0) {
            delete current_mapping[sheet_name][srdr_header];
            requestAnimationFrame(function() {
              origin_elem.parent().removeClass('draggable-dropzone--occupied');
              origin_elem.detach();
              target_elem.append(origin_elem);
              return target_elem.addClass('draggable-dropzone--occupied');
            });
            return;
          }
          return current_mapping[sheet_name][srdr_header] = $(evt.dropzone).attr('index');
        });
      };
      get_sheet_name = function(row_elem) {
        return $(row_elem).find('.sheet-name span').text();
      };
      update_file_headers = function() {
        var b, i, index, sheet_dict, sheet_name, sheet_name_d, srdr_header, ws;
        if (workbook !== void 0) {
          i = 0;
          sheet_name_d = {};
          for (sheet_name in current_mapping) {
            sheet_dict = current_mapping[sheet_name];
            ws = workbook['Sheets'][sheet_name];
            if (current_sheet_name_mapping[sheet_name] in sheet_name_d) {
              current_sheet_name_mapping[sheet_name] = current_sheet_name_mapping[sheet_name] + ' ' + sheet_name_d[current_sheet_name_mapping[sheet_name]];
              sheet_name_d[current_sheet_name_mapping[sheet_name]] += 1;
            } else {
              sheet_name_d[current_sheet_name_mapping[sheet_name]] = 2;
            }
            workbook['SheetNames']['' + i] = current_sheet_name_mapping[sheet_name];
            workbook['Sheets'][current_sheet_name_mapping[sheet_name]] = workbook['Sheets'][sheet_name];
            for (srdr_header in sheet_dict) {
              index = sheet_dict[srdr_header];
              ws[XLSX.utils.encode_col(index) + "1"].t = 's';
              ws[XLSX.utils.encode_col(index) + "1"].v = srdr_header;
              ws[XLSX.utils.encode_col(index) + "1"].w = void 0;
            }
            i += 1;
          }
          XLSX.writeFile(workbook, "fixed_" + filedata.name);
          b = new Blob([
            s2ab(XLSX.write(workbook, {
              bookType: 'xlsx',
              type: 'binary'
            }))
          ], {
            type: "application/octet-stream"
          });
          return new File([b], filedata.name);
        } else {
          return void 0;
          return console.log('workbook not set');
        }
      };
      return s2ab = function(s) {
        var buf, i, view;
        buf = new ArrayBuffer(s.length);
        view = new Uint8Array(buf);
        i = 0;
        while (i < s.length) {
          view[i] = s.charCodeAt(i) & 0xFF;
          i++;
        }
        return buf;
      };
    })();
  });

}).call(this);
