(function() {
  var Caretkeeper, Collapser, Select2Helper, StatusChecker, Timekeeper, add_form_listeners, apply_all_select2, bind_srdr20_saving_mechanism, check, escapeRestrictedCharacters, formatResult, formatResultSelection, init_select2, initializeSwitches, restrictedCharacters, updateSectionFlag, validate_and_send_async_form, validate_form_inputs;

  Caretkeeper = (function() {
    function Caretkeeper() {}

    Caretkeeper.save_caret_position = function() {
      Caretkeeper.focused_elem_id = document.activeElement.id;
      return Caretkeeper.focused_elem_cursor_location = document.activeElement.selectionStart;
    };

    Caretkeeper.restore_caret_position = function() {
      var e;
      try {
        $("#" + Caretkeeper.focused_elem_id).focus();
        return $("#" + Caretkeeper.focused_elem_id)[0].setSelectionRange(Caretkeeper.focused_elem_cursor_location, Caretkeeper.focused_elem_cursor_location);
      } catch (error) {
        e = error;
        return console.log("Error: " + e);
      }
    };

    return Caretkeeper;

  })();

  Timekeeper = (function() {
    function Timekeeper() {}

    Timekeeper._timer_dict = {};

    Timekeeper.clear_timer_for_form = function(form) {
      var formId;
      formId = form.getAttribute('id');
      if (formId in this._timer_dict) {
        return clearTimeout(this._timer_dict[formId]);
      }
    };

    Timekeeper.create_timer_for_form = function(form, duration) {
      var formId;
      Timekeeper.clear_timer_for_form(form);
      formId = form.getAttribute('id');
      this._timer_dict[formId] = setTimeout(function() {
        return validate_and_send_async_form(form);
      }, duration);
      return this._timer_dict[formId];
    };

    return Timekeeper;

  })();

  StatusChecker = (function() {
    function StatusChecker() {}

    StatusChecker.prototype.restore_highlights = false;

    StatusChecker.save_highlights = function() {
      if ($('.empty-input, .empty-associations, .empty-kq').length > 0) {
        return StatusChecker.prototype.restore_highlights = true;
      }
    };

    StatusChecker.restore_highlights = function() {
      if (StatusChecker.prototype.restore_highlights) {
        return StatusChecker.highlight_empty();
      }
    };

    StatusChecker.input_empty = function(input) {
      if ($(input).is('input[type=file]')) {
        if ($(input).closest('.sd-inner').find('img').length) {
          return false;
        } else {
          return true;
        }
      }
      return !$(input).val();
    };

    StatusChecker.get_all_inputs = function() {
      return $('input:not([type="hidden"], .select2-search__field), select, textarea');
    };

    StatusChecker.get_all_unmapped_srdr_kq = function() {
      return $('.srdr-key-questions-box').find('.srdr-kq:not(".kq-mapped")');
    };

    StatusChecker.get_all_unmapped_report_kq = function() {
      return $('.report-key-questions-box').find('.srdr-kq-target-prompt:not(".hide")').parents('.report-kq');
    };

    StatusChecker.check_kq_mapping_status = function() {
      if (StatusChecker.get_all_unmapped_srdr_kq().length > 0) {
        return false;
      }
      if (StatusChecker.get_all_unmapped_report_kq().length > 0) {
        return false;
      }
      return true;
    };

    StatusChecker.check_status = function() {
      var elem, j, len, ref;
      if ($('.zero-nested-associations').length > 0) {
        return false;
      }
      ref = StatusChecker.get_all_inputs();
      for (j = 0, len = ref.length; j < len; j++) {
        elem = ref[j];
        if (StatusChecker.input_empty(elem)) {
          return false;
        }
      }
      return true;
    };

    StatusChecker.remove_highlights = function() {
      StatusChecker.prototype.restore_highlights = false;
      $('.empty-associations').removeClass('empty-associations');
      $('.empty-input').removeClass('empty-input');
      return $('.empty-kq').removeClass('empty-kq');
    };

    StatusChecker.highlight_input = function(input) {
      if ($(input).is('select')) {
        return $(input).parent().find('.select2-container').addClass('empty-input');
      } else {
        return $(input).addClass('empty-input');
      }
    };

    StatusChecker.highlight_empty = function() {
      var completeable, elem, j, len, ref;
      StatusChecker.get_all_unmapped_srdr_kq().addClass('empty-kq');
      StatusChecker.get_all_unmapped_report_kq().addClass('empty-kq');
      ref = StatusChecker.get_all_inputs();
      for (j = 0, len = ref.length; j < len; j++) {
        elem = ref[j];
        if (StatusChecker.input_empty(elem)) {
          completeable = false;
          StatusChecker.highlight_input(elem);
        }
      }
      return $('.zero-nested-associations a').addClass('empty-associations');
    };

    StatusChecker.initialize_listeners = function() {
      $('#status-check-modal[data-reveal]').on('closed.zf.reveal', function(e) {
        return StatusChecker.remove_highlights();
      });
      $(document).keyup(function(e) {
        var code;
        if (!$('#status-check-modal').is(':visible')) {
          return;
        }
        code = e.keyCode || e.which;
        if (code === 13) {
          $('#confirm-status-switch').click();
        }
      });
      $(document).on('click', '.status-switch', function() {
        if (this.id[0] !== "5") {
          if (!(StatusChecker.check_status() || $(this).hasClass('completed'))) {
            $('#status-check-modal').foundation("open");
          } else {
            updateSectionFlag(this);
          }
        } else {
          if (!(StatusChecker.check_kq_mapping_status() || $(this).hasClass('completed'))) {
            $('#status-check-modal').foundation("open");
          } else {
            updateSectionFlag(this);
          }
        }
      });
      $(document).on('click', '#abort-status-switch', function() {
        $('#status-check-modal').foundation("close");
        return StatusChecker.highlight_empty();
      });
      return $(document).on('click', '#confirm-status-switch', function() {
        StatusChecker.remove_highlights();
        updateSectionFlag($('.status-switch')[0]);
        return $('#status-check-modal').foundation("close");
      });
    };

    return StatusChecker;

  })();

  Collapser = (function() {
    function Collapser() {}

    Collapser._state_dict = {};

    Collapser.initialize_states = function() {
      var elem, j, len, ref, results;
      ref = $('.collapse-content');
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        elem = ref[j];
        results.push(Collapser._state_dict[$(elem).data('result-item-id')] = true);
      }
      return results;
    };

    Collapser.initialize_listeners = function() {
      $('.collapsed-icon').on('click', function() {
        var $parent;
        $parent = $($(this).closest('.nested-fields'));
        $parent.find('.collapse-content').removeClass('hide');
        $parent.find('.not-collapsed-icon').removeClass('hide');
        $parent.find('.collapsed-icon').addClass('hide');
        $('textarea').each(function() {
          return this.style.height = this.scrollHeight + "px";
        });
        return Collapser._state_dict[$parent.find('.collapse-content').data('result-item-id')] = false;
      });
      return $('.not-collapsed-icon').on('click', function() {
        var $parent;
        $parent = $($(this).closest('.nested-fields'));
        $parent.find('.collapse-content').addClass('hide');
        $parent.find('.not-collapsed-icon').addClass('hide');
        $parent.find('.collapsed-icon').removeClass('hide');
        return Collapser._state_dict[$parent.find('.collapse-content').data('result-item-id')] = true;
      });
    };

    Collapser.restore_states = function() {
      var $parent, ref, result_item_id, results, state;
      ref = Collapser._state_dict;
      results = [];
      for (result_item_id in ref) {
        state = ref[result_item_id];
        if (!state) {
          $parent = $('.collapse-content[data-result-item-id="' + result_item_id + '"]').closest('.nested-fields');
          $parent.find('.collapse-content').removeClass('hide');
          $parent.find('.not-collapsed-icon').removeClass('hide');
          $parent.find('.collapsed-icon').addClass('hide');
          results.push($('textarea').each(function() {
            return this.style.height = this.scrollHeight + "px";
          }));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    return Collapser;

  })();

  Select2Helper = (function() {
    function Select2Helper() {}

    Select2Helper.copy_sd_outcome_names = function() {
      var sd_outcome_option_set;
      sd_outcome_option_set = new Set();
      $('.sd-outcome-select2 option').each(function(i, option_elem) {
        if (option_elem.text !== '') {
          return sd_outcome_option_set.add(option_elem.text);
        }
      });
      return $('.sd-outcome-select2').each(function(i, select2_elem) {
        return sd_outcome_option_set.forEach(function(key, option_text, sd_outcome_option_set) {
          var newOption;
          if (!$(select2_elem).find("option[value='" + option_text + "']").length) {
            newOption = new Option(option_text, option_text, false, false);
            return $(select2_elem).append(newOption).trigger('change.select2');
          }
        });
      });
    };

    return Select2Helper;

  })();

  validate_and_send_async_form = function(form) {
    if (!validate_form_inputs(form)) {
      return;
    }
    $('.preview-button').attr('disabled', '');
    send_async_form(form);
    $(form).removeClass('dirty');
    return Alpine.store('sdMetaDataStore').hideSaveButtonMenu();
  };

  restrictedCharacters = {
    '<': '&lt;',
    '>': '&gt;'
  };

  escapeRestrictedCharacters = function(string) {
    return String(string).replace(/[<>]/g, function(s) {
      return restrictedCharacters[s];
    });
  };

  formatResultSelection = function(result, container) {
    return escapeRestrictedCharacters(result.text);
  };

  validate_form_inputs = function(form) {
    var $form, $input_elem, https_appended_val, input_elem, input_val, is_form_valid, is_input_valid, j, len, ref, valid_href;
    $form = $(form);
    $form.find('.invalid-url').removeClass('invalid-url');
    is_form_valid = true;
    ref = $form.find('.url-input');
    for (j = 0, len = ref.length; j < len; j++) {
      input_elem = ref[j];
      $input_elem = $(input_elem);
      input_val = $input_elem.val() || "";
      is_input_valid = true;
      if (!(input_val === "")) {
        if (input_val.includes(' ')) {
          $input_elem.parents('div.input').addClass('invalid-url');
          is_input_valid = false;
        } else {
          valid_href = get_valid_URL(input_val);
          if (!valid_href) {
            https_appended_val = "https://" + input_val;
            valid_href = get_valid_URL(https_appended_val);
            if (!valid_href) {
              $input_elem.parents('div.input').addClass('invalid-url');
              is_input_valid = false;
            } else {

            }
          }
        }
      }
      is_form_valid = is_form_valid && is_input_valid;
    }
    return is_form_valid;
  };

  formatResult = function(result) {
    var markup;
    if (result.loading) {
      return result.text;
    }
    markup = '<span>';
    if (~result.text.indexOf('Pirate')) {
      markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> ';
    }
    if (~result.text.indexOf('New item: ')) {
      markup += '';
    }
    markup += result.text;
    if (result.suggestion) {
      markup += ' (suggested by ' + result.suggestion.first_name + ')';
    }
    markup += '</span>';
    return markup;
  };

  init_select2 = function(selector, url) {
    return $(selector).select2({
      selectOnClose: true,
      allowClear: true,
      minimumInputLength: 0,
      placeholder: '-- Select or type other value --',
      ajax: {
        url: url,
        dataType: 'json',
        delay: 250,
        data: function(params) {
          return {
            q: params.term,
            page: params.page
          };
        },
        processResults: function(data, params) {
          params.page = params.page || 1;
          return {
            results: $.map(data.items, function(i) {
              return {
                id: i.id,
                text: i.name,
                suggestion: i.suggestion
              };
            })
          };
        }
      },
      escapeMarkup: function(markup) {
        return markup;
      },
      templateResult: formatResult,
      templateSelection: formatResultSelection
    });
  };

  apply_all_select2 = function() {
    var sd_meta_datum_id;
    init_select2("#sd_meta_datum_funding_source_ids", '/funding_sources');
    init_select2("#sd_meta_datum_key_question_type_ids", '/key_question_types');
    init_select2(".sd_search_database", '/sd_search_databases');
    init_select2(".key_question_type", '/key_question_types');
    init_select2(".sd_picods_type", '/sd_picods_types');
    init_select2(".review_type", '/review_types');
    init_select2(".data_analysis_level", '/data_analysis_levels');
    sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id');
    init_select2(".sd_picods_key_question", "/sd_key_questions?sd_meta_datum_id=" + sd_meta_datum_id);
    $(".sd_picods_key_question").select2({
      placeholder: "-- Select Key Question(s) --"
    });
    $('.apply-select2').select2({
      selectOnClose: true,
      allowClear: true,
      placeholder: '-- Select or type other value --'
    });
    $('.sd-outcome-select2').select2({
      tags: true,
      allowClear: true,
      selectOnClose: true,
      placeholder: '-- Select or type other value --'
    });
    $('.sd-select2, .apply-select2, .sd-outcome-select2').on('select2:unselecting', function(e) {
      return $(this).on('select2:opening', function(event) {
        return event.preventDefault();
      });
    });
    $('.sd-select2').on('select2:unselect', function(e) {
      var sel;
      sel = $(this);
      return setTimeout(function() {
        return sel.off('select2:opening');
      }, 100);
    });
    return Select2Helper.copy_sd_outcome_names();
  };

  add_form_listeners = function(form) {
    var $form, formId;
    $form = $(form);
    formId = $form.attr('id');
    $form.find('input[type="file"]').on('change', function(e) {
      e.preventDefault();
      $form.addClass('dirty');
      return Timekeeper.create_timer_for_form($form[0], 10);
    });
    $form.find('select, input.fdp, input[type="number"]').on('change', function(e) {
      e.preventDefault();
      $form.addClass('dirty');
      return Alpine.store('sdMetaDataStore').showSaveButtonMenu();
    });
    $form.on('cocoon:after-insert cocoon:after-remove', function(e) {
      $form.addClass('dirty');
      return Timekeeper.create_timer_for_form($form[0], 10);
    });
    $("a.remove-figure[data-remote]").on("ajax:success", function(event) {
      return $(this).parent().closest('div').fadeOut();
    });
    $form.find('input[type="text"], textarea').on('paste', function(e) {
      $form.addClass('dirty');
      return Alpine.store('sdMetaDataStore').showSaveButtonMenu();
    });
    return $form.find('input[type="text"], textarea, input[type="number"]').keyup(function(e) {
      var code;
      e.preventDefault();
      code = e.keyCode || e.which;
      if (code === 9 || code === 16 || code === 18 || code === 37 || code === 38 || code === 39 || code === 40 || code === 91) {
        return;
      }
      $form.addClass('dirty');
      return Alpine.store('sdMetaDataStore').showSaveButtonMenu();
    });
  };

  bind_srdr20_saving_mechanism = function() {
    $('form.sd-form').each(function(i, form) {
      var $cocoon_container;
      add_form_listeners(form);
      $cocoon_container = $(form).parents('.cocoon-container');
      return $cocoon_container.on('sd:form-loaded', function(e) {
        add_form_listeners($cocoon_container.children('form'));
        Collapser.initialize_listeners();
        Collapser.restore_states();
        apply_all_select2();
        $('textarea').each(function() {
          return this.style.height = this.scrollHeight + "px";
        });
        Select2Helper.copy_sd_outcome_names();
        return $('.reveal').foundation();
      });
    });
    $('.infoDiv').first().on('sd:replaced-html-content', function(e) {
      Caretkeeper.restore_caret_position();
      return StatusChecker.restore_highlights();
    });
    return $('.infoDiv').first().on('sd:replacing-html-content', function(e) {
      Caretkeeper.save_caret_position();
      return StatusChecker.save_highlights();
    });
  };

  updateSectionFlag = function(domEl) {
    var obj, paramKey, sd_meta_datum_id, sectionId, status, url_base;
    sectionId = domEl.id[0];
    sd_meta_datum_id = $(domEl).attr('data-sd_meta_datum_id');
    status = $(domEl).hasClass('draft');
    paramKey = "section_flag_" + sectionId;
    url_base = $('.sd-form')[0].action;
    $.post(url_base + "/section_update", {
      sd_meta_datum: (
        obj = {},
        obj["" + paramKey] = status,
        obj
      )
    }, function(data) {
      check(sectionId, data.status);
    });
  };

  check = function(panelNumber, status) {
    var check;
    var check_container, link;
    if (status === true || status === 'true') {
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass('draft warning');
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass('completed');
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch span.status-label')).html('Completed');
      if (panelNumber === '3') {
        $('.mapping-kq-title').removeClass('hide');
      }
    } else {
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).removeClass('completed warning');
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch')).addClass('draft');
      $('#'.concat(panelNumber.toString(), '-yes-no-section.status-switch span.status-label')).html('Draft');
      if (panelNumber === '3') {
        $('.mapping-kq-title').addClass('hide');
      }
    }
    check = ' <i class="fa fa-check"></i>';
    link = $("#panel-" + panelNumber + "-label");
    check_container = $(".check-container[panel-number='" + panelNumber + "']");
    check_container.html('');
    if (status === true || status === 'true') {
      check_container.html(check);
      link.css({
        'color': 'green'
      });
    } else {
      link.css({
        'color': 'unset'
      });
    }
    $('.progress-meter').attr('style', 'width: ' + ($('i.fa.fa-check').length * 100.0 / 9.0).toString() + '%');
  };

  initializeSwitches = function() {
    var elem, j, len, ref;
    ref = $('.to-be-checked');
    for (j = 0, len = ref.length; j < len; j++) {
      elem = ref[j];
      check($(elem).find('.check-container').attr('panel-number'), true);
      $(elem).removeClass('to-be-checked');
    }
  };

  document.addEventListener('DOMContentLoaded', function() {
    return (function() {
      if ($('body.sd_meta_data.edit').length === 0) {
        return;
      }
      StatusChecker.initialize_listeners();
      Collapser.initialize_states();
      Collapser.initialize_listeners();
      initializeSwitches();
      bind_srdr20_saving_mechanism();
      setTimeout((function() {
        return apply_all_select2();
      }), 50);
      $('textarea').each(function() {
        return this.style.height = this.scrollHeight + "px";
      });
      return $(document).on('click', '#save-dirty-forms-button', function() {
        return $('form.dirty').each((function(_this) {
          return function(i, form) {
            return validate_and_send_async_form(form);
          };
        })(this));
      });
    })();
  });

}).call(this);
