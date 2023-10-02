(function() {
  var documentCode;

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
    var escapeRestrictedCharacters, findActivePrereq, formatResult, formatResultSelection, relevantIDsClasses, restrictedCharacters, updateCards;
    if ($('body.public_data.show, .extraction_forms_projects.build, .extraction_forms_projects_sections, .extractions').length > 0) {
      $('.attach-me').each(function() {
        var tether;
        tether = new Tether({
          element: this,
          target: "label[for='" + ($("[data-attach-source='" + this.getAttribute('data-attach-target') + "']")[0].id) + "']",
          attachment: "center left",
          targetAttachment: "center right",
          offset: '-1px -10px'
        });
        setTimeout((function() {
          return tether.position();
        }), 50);
        return true;
      });
      $('.attach-me').removeClass('hide');
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
      $('#preview .question-row-column .select2').select2({
        placeholder: '-- Select or type other value --',
        width: '100%',
        minimumInputLength: 0,
        ajax: {
          url: function() {
            var id;
            id = $(this).closest('.question-row-column').data('question-row-column-id');
            return '/question_row_columns/' + id + '/answer_choices';
          },
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
      $('#extraction_forms_projects_section_section_id').select2({
        placeholder: '-- Select or type other value --',
        width: '100%',
        minimumInputLength: 0,
        ajax: {
          url: '/sections.json',
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
      $('#preview .card input[type="text"]').on('input', function(e) {
        var currentValue, that;
        e.preventDefault();
        that = $(this);
        currentValue = that.val();
        that.data('previous-value', currentValue);
      });
      $('#preview .card input[type="number"]').on('input', function(e) {
        var currentValue, that;
        e.preventDefault();
        that = $(this);
        currentValue = that.val();
        that.data('previous-value', currentValue);
      });
      $('#preview .card input[type="checkbox"]').on('mouseup', function(e) {
        var isChecked, that;
        e.preventDefault();
        that = $(this);
        isChecked = that.prop('checked');
        that.data('previous-value', !isChecked);
      });
      $('#preview .card select').on('blur', function(e) {
        var isSelected, that;
        e.preventDefault();
        that = $(this);
        isSelected = that.val();
        that.data('previous-value', isSelected);
      });
      $('#preview .card select.select2').on('select2:close', function(e) {
        var isSelected, that;
        that = $(this);
        isSelected = that.val();
        that.data('previous-value', isSelected);
      });
      $('#preview .card input[type="radio"]').on('blur', function(e) {
        var that;
        e.preventDefault();
        that = $(this);
        that.data('previous-value', that.is(':checked'));
        that.siblings('input[type="radio"]').each(function() {
          return $(this).data('previous-value', $(this).is(':checked'));
        });
      });
      updateCards = function() {
        if ($('body.public_data.show').length > 0) {
          return;
        }
        $('.card').addClass('hide');
        return $('.kqp-selector').each(function() {
          var isChecked, kqId, that;
          that = $(this);
          isChecked = $(this).prop('checked');
          kqId = $(this).attr('data-kqp-selection-id');
          $("[data-kqp-selection-id=" + kqId + "]").each(function() {
            if ($(this) !== that) {
              return $(this).prop('checked', isChecked);
            }
          });
          if (isChecked) {
            return $('.card.kqreq-' + kqId).removeClass('hide');
          }
        });
      };
      $('input').trigger('change');
      $('.key-question-selector input[type="checkbox"]').on('change', function(e) {
        e.preventDefault();
        updateCards();
        return $('#extractions-key-questions-projects-selections-form').submit();
      });
      $(document).ready(function() {
        return updateCards();
      });
      findActivePrereq = function(that) {
        var active, prereq;
        prereq = that.data('prereq');
        if (that.is('input[type="checkbox"]') || that.is('input[type="radio"]')) {
          active = that.is(':checked');
        } else if (that.is('option')) {
          active = that.is(':selected');
        } else {
          active = !!that.val();
        }
        if (!prereq) {
          if ($.isArray(active)) {
            that.find(':selected').each(function() {
              var temp;
              temp = $(this).data('prereq');
              if ($('.' + temp).length || $('.off-' + temp).length) {
                return prereq = temp;
              }
            });
          } else {
            prereq = that.find(':selected').data('prereq');
          }
        }
        return {
          active: active,
          prereq: prereq
        };
      };
      relevantIDsClasses = '#preview .card input, #preview .card select, #preview .card textarea';
      $(relevantIDsClasses).on('change keyup dependencies:update', function(e) {
        var preReqLookup;
        e.preventDefault();
        e.stopPropagation();
        preReqLookup = {};
        $("input[data-prereq],option[data-prereq]").each(function(idx, element) {
          var active, prereq, ref;
          ref = findActivePrereq($(element)), active = ref.active, prereq = ref.prereq;
          if (preReqLookup[prereq] === void 0) {
            preReqLookup[prereq] = active;
          } else if (active && preReqLookup[prereq] === false) {
            preReqLookup[prereq] = active;
          }
          return true;
        });
        return Object.keys(preReqLookup).forEach(function(prereq) {
          if (preReqLookup[prereq]) {
            return $('.' + prereq).removeClass(prereq).addClass('off-' + prereq);
          } else {
            return $('.off-' + prereq).removeClass('off-' + prereq).addClass(prereq);
          }
        });
      });
      return $(relevantIDsClasses).trigger("dependencies:update");
    }
  };

}).call(this);
