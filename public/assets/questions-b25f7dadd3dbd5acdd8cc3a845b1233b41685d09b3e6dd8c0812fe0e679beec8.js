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
    var allowsFollowup, hideHeaders, multiSelect;
    multiSelect = ['Checkbox (select multiple)', 'Dropdown (select one)', 'Radio (select one)', 'Select one (with write-in option)', 'Select multiple (with write-in option)'];
    allowsFollowup = ['Checkbox (select multiple)', 'Radio (select one)'];
    $('.fieldset').on('change', function() {
      var _value, that;
      that = $(this);
      that.find('.field-options').hide();
      that.find('.links').hide();
      _value = that.find('select').children(':selected').text();
      if (indexOf.call(multiSelect, _value) >= 0) {
        that.find('.field-options.field-option-type-answer_choice').show();
        that.find('.links').show();
        if (indexOf.call(allowsFollowup, _value) >= 0) {
          return that.find('.followup_container').css('visibility', 'visible');
        } else {
          return that.find('.followup_container').css('visibility', 'hidden');
        }
      } else if (_value === 'Text Field (alphanumeric)') {
        that.find('.field-options.field-option-type-min_length').show();
        return that.find('.field-options.field-option-type-max_length').show();
      } else if (_value === 'Numeric Field (numeric)') {
        that.find('.field-options.field-option-type-additional_char').show();
        that.find('.field-options.field-option-type-min_value').show();
        return that.find('.field-options.field-option-type-max_value').show();
      } else if (_value === 'numeric_range') {
        that.find('.field-options.field-option-type-min_value').show();
        return that.find('.field-options.field-option-type-max_value').show();
      } else if (_value === 'scientific') {
        that.find('.field-options.field-option-type-min_value').show();
        that.find('.field-options.field-option-type-max_value').show();
        that.find('.field-options.field-option-type-coefficient').show();
        return that.find('.field-options.field-option-type-exponent').show();
      }
    });
    $('.fieldset').trigger('change');
    hideHeaders = function(_tableRows) {
      var _colCnt, _rowCnt;
      _rowCnt = _tableRows.length;
      _colCnt = _tableRows[0].cells.length;
      if (_rowCnt === 2) {
        _tableRows.find('td:first-child, th:first-child').hide();
      }
      if (_colCnt === 2) {
        return _tableRows.find('th:nth-child(-n+3)').hide();
      }
    };
    $('.clean-table table, table.dependency-table').each(function() {
      var _tableRows;
      _tableRows = $(this).find('tr');
      if (_tableRows.length > 1) {
        return hideHeaders(_tableRows);
      }
    });
    $('#add_column_link').click(function(event) {
      var $form;
      event.preventDefault();
      $form = $("form[id^='edit_question_']");
      $form.ajaxSubmit({
        dataType: 'script',
        success: function() {
          $('#add_column_button').click();
        }
      });
      return false;
    });
    return $('#add_row_link').click(function(event) {
      var $form;
      event.preventDefault();
      $form = $("form[id^='edit_question_']");
      $form.ajaxSubmit({
        dataType: 'script',
        success: function() {
          $('#add_row_button').click();
        }
      });
      return false;
    });
  };

  window.questionsCoffeeScript = documentCode;

}).call(this);
