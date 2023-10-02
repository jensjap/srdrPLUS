(function() {
  var documentCode,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  document.addEventListener('DOMContentLoaded', function() {
    if ($('body.extractions.work').length > 0) {
      return;
    }
    return documentCode();
  });

  document.addEventListener('extractionSectionLoaded', function() {
    return documentCode();
  });

  documentCode = function() {
    var add_change_listeners_to_questions, apply_coloring, apply_consolidation_dropdown, dt, dtComparisonList, get_extractor_names, get_number_of_extractions, get_question_type, get_question_value, last_col, tableKey;
    if (!($('.extractions').length > 0)) {
      return;
    }
    $('.index-extractions-select2').select2();
    $('.new-extraction-select2').select2();
    $('.new-extraction-select2-multi').select2({
      multiple: 'true',
      placeholder: '-- Select citation to be extracted --',
      ajax: {
        url: '/api/v1/citations/project_citations_query',
        dataType: 'json',
        delay: 250,
        data: function(params) {
          return {
            q: params.term,
            project_id: $('#citations-project-id').data('project-id')
          };
        }
      }
    });
    $('.consolidation-select2').select2();
    $('.consolidation-select2-multi').select2({
      multiple: 'true'
    });
    $('.change-outcome-link').click(function(e) {
      $('#results-panel > .table-container').html('<br><br><br><h1>loading..</h1>');
      e.preventDefault();
    });
    $('#results-panel .table-container').scroll(function() {
      if ($(this).prop('scrollHeight') - $(this).height() === $(this).scrollTop()) {
        console.log('Scrolled to Bottom');
      }
    });
    if ($('body.extractions.index, body.extractions.comparison_tool').length > 0) {
      $('.projects-users-role').hover(function() {
        $(this).closest('.projects-users-role').find('.projects-users-role-select').removeClass('hide');
        return $(this).closest('.projects-users-role').find('.projects-users-role-label').addClass('hide');
      }, function() {
        if ($(this).closest('.projects-users-role').attr('dropdown-active') === 'false') {
          $(this).closest('.projects-users-role').find('.projects-users-role-select').addClass('hide');
          return $(this).closest('.projects-users-role').find('.projects-users-role-label').removeClass('hide');
        }
      });
      $('body').on('click', function(event) {
        return $('.projects-users-role-select').each(function() {
          if ((!$(event.target).closest('.projects-users-role-select').is(this)) && (!$(event.target).hasClass('projects-users-role-label'))) {
            $(this).closest('.projects-users-role').find('.projects-users-role-select').addClass('hide');
            $(this).closest('.projects-users-role').find('.projects-users-role-label').removeClass('hide');
            return $(this).closest('.projects-users-role').attr('dropdown-active', 'false');
          }
        });
      });
      $('.projects-users-role').on('click', function(event) {
        return $(this).closest('.projects-users-role').attr('dropdown-active', 'true');
      });
      $('.projects-users-role-select select').on('change', function(event) {
        $(this).closest('form').submit();
        $(this).closest('.projects-users-role').find('.projects-users-role-select').addClass('hide');
        $(this).closest('.projects-users-role').find('.projects-users-role-label').removeClass('hide');
        return $(this).closest('.projects-users-role').attr('dropdown-active', 'false');
      });
      tableKey = window.location.pathname;
      dt = $('table.extractions-list').DataTable({
        "columnDefs": [
          {
            "orderable": false,
            "targets": "_all"
          }
        ],
        "lengthMenu": [[50, 100, 500, -1], [50, 100, 500, "All"]],
        "pageLength": -1,
        "pagingType": "full_numbers",
        "stateSave": true,
        "stateSaveParams": function(settings, data) {
          return data.search.search = "";
        },
        "stateDuration": 0,
        "stateSaveCallback": function(settings, data) {
          var obj;
          return fetch('/profile/storage', {
            method: "POST",
            headers: {
              Accept: "application/json",
              "Content-Type": "application/json",
              "X-Requested-With": "XMLHttpRequest",
              "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
            },
            body: JSON.stringify({
              storage: (
                obj = {},
                obj["DataTables-" + tableKey] = data,
                obj
              )
            })
          });
        },
        "stateLoadCallback": function(settings, cb) {
          fetch('/profile/storage').then(function(response) {
            return response.json().then(function(data) {
              return cb(data["DataTables-" + tableKey]);
            });
          });
          return void 0;
        }
      });
      dt.draw();
      last_col = 6;
      $('table.extractions-list').on('click', '.table-sortable', function(e) {
        var col, element;
        element = $(this);
        col = element.data('sorting-col');
        if (element.hasClass('sorting')) {
          dt.order([col, 'asc']).draw();
          element.removeClass('sorting');
          element.addClass('sorting_asc');
        } else if (element.hasClass('sorting_asc')) {
          dt.order([col, 'desc']).draw();
          element.removeClass('sorting_asc');
          element.addClass('sorting_desc');
        } else if (element.hasClass('sorting_desc')) {
          dt.order([0, 'desc']).draw();
          element.removeClass('sorting_desc');
          element.addClass('sorting');
          $('[data-sorting-col=0]').removeClass('sorting_desc');
        }
        if (last_col !== col) {
          $("[data-sorting-col=" + last_col + "]").addClass('sorting');
        }
        return last_col = col;
      });
      $('[data-sorting-col=0]').removeClass('sorting_desc');
      dtComparisonList = $('table.comparisons-list').DataTable({
        "paging": false,
        "info": false,
        "columnDefs": [
          {
            "orderable": false,
            "targets": [3]
          }
        ]
      });
      dtComparisonList.rows({
        page: 'current'
      }).invalidate();
      dtComparisonList.draw();
    }
    if ($('body.extractions.work').length > 0) {
      $('#outcome_populations_selector_eefpst1_id').change(function(event) {
        return $.ajax({
          url: '/extractions_extraction_forms_projects_sections_type1s/' + this.value + '/get_results_populations',
          type: 'GET',
          dataType: 'script',
          error: function() {
            return alert('Server busy. Please try again later.');
          },
          timeout: 5000
        });
      });
    }
    if ($('body.extractions').length > 0) {
      $('.consolidate .edit-type1-link').click(function(e) {
        var $modal, $this, urlString;
        e.preventDefault();
        e.stopPropagation();
        $this = $(this);
        $modal = $('#edit-type1-modal');
        urlString = 'edit_type1_across_extractions?';
        urlString = urlString.concat('type1_id=');
        urlString = urlString.concat($this.data('type1-id'));
        urlString = urlString.concat('&efps_id=');
        urlString = urlString.concat($this.data('efps-id'));
        urlString = urlString.concat('&eefps_id=');
        urlString = urlString.concat($this.data('eefps-id'));
        $($this.data('extraction-ids')).each(function(idx, elem) {
          urlString = urlString.concat('&extraction_ids[]=');
          return urlString = urlString.concat(elem);
        });
        return $.ajax(urlString).done(function(resp) {
          return $modal.html(resp).foundation('open');
        });
      });
      $('#toggle-sections-link').click(function(e) {
        e.preventDefault;
        $('#toggle-sections-link .toggle-hide').toggleClass('hide');
        $('.toggle-sections-link-medium-2-0-hide').toggleClass('medium-2 medium-0 hide');
        return $('.toggle-sections-link-medium-10-12').toggleClass('medium-10 medium-12');
      });
      $('#toggle-consolidated-extraction-link').click(function(e) {
        e.preventDefault;
        $('#toggle-consolidated-extraction-link .toggle-hide').toggleClass('hide');
        $('.toggle-consolidated-extraction-link-medium-8-12').toggleClass('medium-8 medium-12');
        return $('.toggle-consolidated-extraction-link-medium-4-0-hide').toggleClass('medium-4 medium-0 hide');
      });
      get_number_of_extractions = function() {
        var $questions, $rows;
        $questions = $('.consolidation-data-row');
        if ($questions.length > 0) {
          $rows = $questions.children('tr');
          return ($rows.length > 0 ? Math.max(0, $rows.first().children('td').length - 1) : 0);
        }
      };
      get_extractor_names = function() {
        var $panels, extractor_names;
        $panels = $('div[id^="panel-tab-"]');
        if ($panels.length > 0) {
          extractor_names = [];
          $panels.first().find('th[extractor-name]').each(function(extractor_id, extractor_elem) {
            return extractor_names.push($(extractor_elem).attr('extractor-name'));
          });
          return extractor_names;
        }
        return [];
      };
      get_question_type = function(question) {
        var cb_input_arr, drop_input_arr, rb_input_arr;
        if ($(question).find('input[type="number"]').length === 1) {
          return "numeric";
        }
        if ($(question).find('textarea').length === 1) {
          return "text";
        }
        cb_input_arr = $(question).find('div.input.check_boxes');
        if (cb_input_arr.length > 0) {
          return "checkbox";
        }
        drop_input_arr = $(question).find('select');
        if (drop_input_arr.length > 0) {
          return "dropdown";
        }
        rb_input_arr = $(question).find('div.input.radio_buttons');
        if (rb_input_arr.length > 0) {
          return "radio_buttons";
        }
        return "unclear";
      };
      get_question_value = function(question) {
        var cb_arr, drop_input, numeric_value, rb_selected, sign_option, val;
        switch (get_question_type(question)) {
          case "text":
            return $(question).find('textarea')[0].value;
          case "numeric":
            sign_option = $($(question).find('select')[0]).children('option').filter(':selected')[0];
            numeric_value = "";
            if (sign_option) {
              numeric_value += sign_option.value || "";
            }
            numeric_value += "&&&&&";
            numeric_value += $(question).find('input[type="number"]')[0].value || "";
            return numeric_value;
          case "checkbox":
            cb_arr = [];
            $(question).find('input.check_boxes').filter(':checked').each(function(input_id, input_elem) {
              return cb_arr.push(input_elem.value);
            });
            return (cb_arr.length > 0 ? cb_arr.join("&&") : "");
          case "dropdown":
            drop_input = $(question).find('select')[0];
            if (drop_input) {
              val = $(drop_input).val();
              return (val ? val : "");
            }
            break;
          case "radio_buttons":
            rb_selected = $(question).find('input.radio_buttons').filter(':checked');
            return (rb_selected.length === 1 ? rb_selected[0].value : "");
          default:
            return "";
        }
      };
      add_change_listeners_to_questions = function() {
        var number_of_extractions;
        number_of_extractions = get_number_of_extractions();
        return $('.consolidation-data-row').each(function(row_id, row_elem) {
          return $(row_elem).children('tr').each(function(arm_row_id, arm_row_elem) {
            return $(arm_row_elem).find('td tbody').each(function(cell_id, cell_elem) {
              return $(cell_elem).find('tr').each(function(tr_id, tr_elem) {
                return $(tr_elem).find('td').each(function(td_id, td_elem) {
                  var select_elem;
                  if (td_id !== 0 && cell_id === number_of_extractions) {
                    switch (get_question_type(td_elem)) {
                      case "text":
                        return $(td_elem).find('input.string').keyup(function() {
                          return apply_coloring();
                        });
                      case "numeric":
                        $(td_elem).find('input.number').keyup(function() {
                          return apply_coloring();
                        });
                        return $(td_elem).find('select').change(function() {
                          return apply_coloring();
                        });
                      case "checkbox":
                        return $(td_elem).find('input.check_boxes').each(function(input_id, input_elem) {
                          return $(input_elem).change(function() {
                            return apply_coloring();
                          });
                        });
                      case "dropdown":
                        select_elem = $(td_elem).find('select');
                        return $(select_elem).change(function() {
                          return apply_coloring();
                        });
                      case "radio_buttons":
                        return $(td_elem).find('input.radio_buttons').each(function(rb_index, rb_input) {
                          return $(rb_input).change(function() {
                            return apply_coloring();
                          });
                        });
                    }
                  }
                });
              });
            });
          });
        });
      };
      apply_consolidation_dropdown = function() {
        var extractor_names, number_of_extractions;
        number_of_extractions = get_number_of_extractions();
        extractor_names = get_extractor_names();
        return $('.consolidation-data-row').each(function(row_id, row_elem) {
          var $drop_elem, c_dict, drop_option, extraction_id, i, ref;
          c_dict = {};
          $drop_elem = $("<select>");
          for (extraction_id = i = 0, ref = number_of_extractions; 0 <= ref ? i <= ref : i >= ref; extraction_id = 0 <= ref ? ++i : --i) {
            drop_option = $("<option>");
            drop_option.text(extractor_names[extraction_id]);
            drop_option.val(extraction_id);
            if (extraction_id === number_of_extractions) {
              drop_option.prop("selected", true);
            }
            $drop_elem.append(drop_option);
          }
          $(row_elem).children('tr').each(function(arm_row_id, arm_row_elem) {
            c_dict[arm_row_id] || (c_dict[arm_row_id] = {});
            return $(arm_row_elem).find('td tbody').each(function(cell_id, cell_elem) {
              var base;
              (base = c_dict[arm_row_id])[cell_id] || (base[cell_id] = {});
              return $(cell_elem).find('tr').each(function(tr_id, tr_elem) {
                var base1;
                (base1 = c_dict[arm_row_id][cell_id])[tr_id] || (base1[tr_id] = {});
                return $(tr_elem).find('td').each(function(td_id, td_elem) {
                  var base2;
                  if (td_id !== 0) {
                    (base2 = c_dict[arm_row_id][cell_id][tr_id])[td_id] || (base2[td_id] = {});
                    c_dict[arm_row_id][cell_id][tr_id][td_id]["question_type"] = get_question_type(td_elem);
                    return c_dict[arm_row_id][cell_id][tr_id][td_id]["question_value"] = get_question_value(td_elem);
                  }
                });
              });
            });
          });
          $drop_elem.change(function() {
            return $(row_elem).children('tr').each(function(arm_row_id, arm_row_elem) {
              return $(arm_row_elem).find('td tbody').each(function(cell_id, cell_elem) {
                if (cell_id === number_of_extractions) {
                  $(cell_elem).find('tr').each(function(tr_id, tr_elem) {
                    return $(tr_elem).find('td').each(function(td_id, td_elem) {
                      var cb_arr, new_sign, new_val, new_value, select_elem;
                      if (td_id !== 0) {
                        cell_id = $drop_elem.children("option").filter(":selected")[0].value;
                        new_value = c_dict[arm_row_id][cell_id][tr_id][td_id]["question_value"];
                        switch (c_dict[arm_row_id][cell_id][tr_id][td_id]["question_type"]) {
                          case "text":
                            $(td_elem).find('textarea').val(new_value);
                            $(td_elem).find('textarea').trigger('keyup');
                            return $(td_elem).find('textarea').trigger('input');
                          case "numeric":
                            new_sign = new_value.split("&&&&&")[0];
                            new_val = new_value.split("&&&&&").pop();
                            $(td_elem).find('select').val(new_sign);
                            $(td_elem).find('select').trigger('change');
                            $(td_elem).find('select').trigger('input');
                            $(td_elem).find('input[type="number"]').val(new_val);
                            $(td_elem).find('input[type="number"]').trigger('keyup');
                            return $(td_elem).find('input[type="number"]').trigger('input');
                          case "checkbox":
                            cb_arr = new_value.length > 0 ? new_value.split("&&") : [];
                            return $(td_elem).find('input.check_boxes').each(function(input_id, input_elem) {
                              var ref1;
                              if (ref1 = input_elem.value, indexOf.call(cb_arr, ref1) >= 0) {
                                $(input_elem).prop('checked', true);
                              } else {
                                $(input_elem).prop('checked', false);
                              }
                              $(input_elem).trigger('change');
                              return $(input_elem).trigger('input');
                            });
                          case "dropdown":
                            select_elem = $(td_elem).find('select');
                            $(select_elem).val(new_value);
                            $(select_elem).trigger('change');
                            return $(select_elem).trigger('input');
                          case "radio_buttons":
                            return $(td_elem).find('input.radio_buttons').each(function(rb_index, rb_input) {
                              if (rb_input.value === new_value) {
                                $(rb_input).prop('checked', true);
                              } else {
                                $(rb_input).prop('checked', false);
                              }
                              $(rb_input).trigger('change');
                              return $(rb_input).trigger('input');
                            });
                        }
                      }
                    });
                  });
                }
                return apply_coloring();
              });
            });
          });
          return $(row_elem).find('div#consolidation-dropdown').html($drop_elem);
        });
      };
      apply_coloring = function() {
        var extractor_arr, number_of_extractions;
        number_of_extractions = get_number_of_extractions();
        extractor_arr = get_extractor_names();
        return $('.consolidation-data-row').each(function(row_id, row_elem) {
          var b_dict, consolidated_cell, consolidated_value;
          b_dict = {};
          consolidated_cell = {};
          consolidated_value = {};
          $(row_elem).children('tr').each(function(arm_row_id, arm_row_elem) {
            b_dict[arm_row_id] || (b_dict[arm_row_id] = {});
            return $(arm_row_elem).find('td tbody').each(function(cell_id, cell_elem) {
              return $(cell_elem).find('tr').each(function(tr_id, tr_elem) {
                var base;
                (base = b_dict[arm_row_id])[tr_id] || (base[tr_id] = {});
                consolidated_cell[tr_id] || (consolidated_cell[tr_id] = {});
                consolidated_value[tr_id] || (consolidated_value[tr_id] = {});
                return $(tr_elem).find('td').each(function(td_id, td_elem) {
                  var base1, base2, question_value;
                  if (td_id !== 0) {
                    if (cell_id !== number_of_extractions) {
                      question_value = get_question_value(td_elem);
                      (base1 = b_dict[arm_row_id][tr_id])[td_id] || (base1[td_id] = {});
                      (base2 = b_dict[arm_row_id][tr_id][td_id])[question_value] || (base2[question_value] = 0);
                      return b_dict[arm_row_id][tr_id][td_id][question_value]++;
                    } else {
                      consolidated_cell[tr_id][td_id] = $(td_elem);
                      return consolidated_value[tr_id][td_id] = get_question_value(td_elem);
                    }
                  }
                });
              });
            });
          });
          return $.each(b_dict, function(arm_row_id, tr_dict) {
            var color_dict, value_arr;
            color_dict = {};
            value_arr = [];
            $.each(tr_dict, function(tr_id, td_dict) {
              color_dict[tr_id] || (color_dict[tr_id] = {});
              return $.each(td_dict, function(td_id, value_dict) {
                color_dict[tr_id][td_id] = "";
                return $.each(value_dict, function(value, value_count) {
                  value_arr.push(value);
                  if (value_count !== number_of_extractions) {
                    if (consolidated_value[tr_id][td_id] !== "") {
                      return color_dict[tr_id][td_id] = "#D1F2EB";
                    } else {
                      return color_dict[tr_id][td_id] = "#FADBD8";
                    }
                  } else {
                    if (value !== consolidated_value[tr_id][td_id]) {
                      return color_dict[tr_id][td_id] = "#D1F2EB";
                    }
                  }
                });
              });
            });
            return $.each(color_dict, function(tr_id, color_tr_dict) {
              return $.each(color_tr_dict, function(td_id, color) {
                if (!!consolidated_cell[tr_id][td_id]) {
                  return consolidated_cell[tr_id][td_id].css('background', color);
                }
              });
            });
          });
        });
      };
      add_change_listeners_to_questions();
      apply_coloring();
      return apply_consolidation_dropdown();
    }
  };

}).call(this);
