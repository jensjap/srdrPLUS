(function() {
  var documentCode, get_result_value;

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
    return $('.links.add-comparison').on('cocoon:before-insert', function() {
      return $(this).hide();
    }).on('cocoon:after-insert', function(e, insertedItem) {
      var bac_anova_handler, bac_select;
      $(insertedItem).find('.links.add-comparate-group a').click();
      $(insertedItem).find('.links.add-comparate-group a').click();
      $('.links.add-comparate-group a').hide();
      $(insertedItem).find('.links.add-comparate').each(function() {
        return $(this).find('a').click();
      });
      $('.nested-fields > .comparate-groups').find('.nested-fields.comparates').first().after($('<div style="text-align: center; font-weight: normal;">vs.</div>'));
      if ($('.wac-comparate-fields').length === 2) {
        $('.wac-comparate-fields:eq(1)').find('select option').filter(function() {
          return this.text.includes('Baseline');
        }).attr('selected', true);
      }
      $('.links.add-anova a').click();
      $('.links.add-anova a').addClass('disabled');
      $('.links.add-comparison a').addClass('disabled');
      bac_select = $(insertedItem).find('.bac-select').first();
      bac_anova_handler = function(event) {
        if ($(event.target).find('option:selected').first().val() === "000") {
          $(event.target).closest('.comparate-groups').children().hide();
          $(event.target).closest('.comparates').show();
          $(event.target).closest('.comparates').find('.add-comparate').hide();
          $('.submit-comparison').toggleClass('hide');
          return $('.submit-anova').toggleClass('hide');
        } else {
          $(event.target).closest('.comparate-groups').children().show();
          $(event.target).closest('.comparates').find('.add-comparate').show();
          $('.submit-comparison').toggleClass('hide');
          return $('.submit-anova').toggleClass('hide');
        }
      };
      if (bac_select) {
        bac_select.find('option').first().text('All Arms (ANOVA)').val('000');
        bac_select.change(bac_anova_handler);
        return bac_select.trigger('change');
      }
    });
  };

  get_result_value = function(td_elem) {
    var add_change_listeners_to_results_section, get_result_elem, get_result_extractor_names, get_result_number_of_extractions, inputs, result_section_coloring, result_section_dropdowning;
    inputs = $(td_elem).find("input.string");
    return (inputs.length > 0 ? inputs[0].value : "");
    get_result_elem = function(td_elem) {
      inputs = $(td_elem).find("input.string");
      return (inputs.length > 0 ? inputs[0] : null);
    };
    get_result_number_of_extractions = function() {
      var questions, rows;
      questions = $('table.consolidated-data-table tbody');
      if (questions.length > 0) {
        rows = $(questions[0]).find('tr');
        return Math.max(0, rows.length - 1);
      }
      return 0;
    };
    get_result_extractor_names = function() {
      var $rows, extractor_names, questions;
      questions = $('table.consolidated-data-table tbody');
      if (questions.length > 0) {
        extractor_names = [];
        $rows = $(questions[0]).find('tr');
        $rows.each(function(tr_id, tr_elem) {
          return $(tr_elem).find("td.extractor-name").each(function(td_id, td_elem) {
            if (td_id === 0) {
              return extractor_names.push(td_elem.innerHTML);
            }
          });
        });
        return extractor_names;
      }
      return [];
    };
    add_change_listeners_to_results_section = function() {
      var number_of_extractions;
      number_of_extractions = get_result_number_of_extractions();
      return $('table.consolidated-data-table tbody').each(function(row_id, row_elem) {
        return $(row_elem).find('tr').each(function(tr_id, tr_elem) {
          return $(tr_elem).find('td').not('.extractor-name').each(function(td_id, td_elem) {
            var input_elem;
            if (tr_id === number_of_extractions) {
              input_elem = get_result_elem(td_elem);
              if (input_elem) {
                return $(input_elem).keyup(function() {
                  return result_section_coloring();
                });
              }
            }
          });
        });
      });
    };
    result_section_coloring = function() {
      var number_of_extractions;
      number_of_extractions = get_result_number_of_extractions();
      return $('table.consolidated-data-table tbody').each(function(row_id, row_elem) {
        var a_dict, color;
        a_dict = {};
        $(row_elem).find('tr').each(function(tr_id, tr_elem) {
          return $(tr_elem).find('td').not('.extractor-name').each(function(td_id, td_elem) {
            var base, name;
            if (tr_id < number_of_extractions) {
              a_dict["counts"] || (a_dict["counts"] = {});
              (base = a_dict["counts"])[name = td_elem.innerHTML] || (base[name] = 0);
              return a_dict["counts"][td_elem.innerHTML]++;
            } else {
              a_dict["consolidated_value"] = get_result_value(td_elem);
              return a_dict["consolidated_elem"] = td_elem;
            }
          });
        });
        color = "#E8DAEF";
        return $.each(a_dict["counts"], function(value, count) {
          if (count !== number_of_extractions) {
            if (a_dict["consolidated_value"] !== "") {
              color = "#D1F2EB";
            } else {
              color = "#FADBD8";
            }
          } else {
            if (a_dict["consolidated_value"] === value) {
              color = "#E8DAEF";
            } else {
              color = "#D1F2EB";
            }
          }
          return $(a_dict["consolidated_elem"]).css('background', color);
        });
      });
    };
    result_section_dropdowning = function() {
      var extractor_names, number_of_extractions;
      number_of_extractions = get_result_number_of_extractions();
      extractor_names = get_result_extractor_names();
      return $('td.consolidated-data-cell').each(function(cell_id, cell_elem) {
        var $drop_elem, a_dict, drop_option, extraction_id, i, ref;
        a_dict = {};
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
        $(cell_elem).find('table.consolidated-data-table tbody').each(function(row_id, row_elem) {
          a_dict[row_id] || (a_dict[row_id] = {});
          return $(row_elem).find('tr').each(function(tr_id, tr_elem) {
            return $(tr_elem).find('td').not('.extractor-name').each(function(td_id, td_elem) {
              if (tr_id < number_of_extractions) {
                return a_dict[row_id][tr_id] = td_elem.innerHTML;
              } else {
                return a_dict[row_id][tr_id] = get_result_value(td_elem);
              }
            });
          });
        });
        $drop_elem.change(function() {
          return $(cell_elem).find('table.consolidated-data-table tbody').each(function(row_id, row_elem) {
            return $(row_elem).find('tr').each(function(tr_id, tr_elem) {
              return $(tr_elem).find('td').not('.extractor-name').each(function(td_id, td_elem) {
                var input_elem, selected_id;
                if (tr_id === number_of_extractions) {
                  selected_id = $drop_elem.children("option").filter(":selected")[0].value;
                  input_elem = get_result_elem(td_elem);
                  $(input_elem).val(a_dict[row_id][selected_id]);
                  result_section_coloring();
                  return $(input_elem).trigger('keyup');
                }
              });
            });
          });
        });
        return $(cell_elem).find("div.consolidated-dropdown").html($drop_elem);
      });
    };
    result_section_coloring();
    result_section_dropdowning();
    return add_change_listeners_to_results_section();
  };

}).call(this);
