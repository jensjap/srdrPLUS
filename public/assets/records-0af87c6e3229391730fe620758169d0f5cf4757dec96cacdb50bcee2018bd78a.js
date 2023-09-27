(function() {
  var documentCode;

  document.addEventListener('DOMContentLoaded', function() {
    if ($('body.extractions.work').length > 0) {
      return;
    }
    if ($('body.public_data.show').length > 0) {
      return;
    }
    return documentCode();
  });

  document.addEventListener('extractionSectionLoaded', function() {
    return documentCode();
  });

  documentCode = function() {
    var submitForm, timers;
    timers = {};
    submitForm = function(form) {
      return function() {
        return form.submit();
      };
    };
    $(document).on('input propertychange', 'form.edit_extractions_extraction_forms_projects_sections_question_row_column_field select, form.edit_record select, form.edit_record input[type="checkbox"], form.edit_record input[type="radio"], form.edit_record input[type="number"]', function(e) {
      var $form, formId, valueChanged;
      e.preventDefault();
      valueChanged = false;
      if (e.type === 'propertychange') {
        valueChanged = e.originalEvent.propertyName === 'value';
      } else {
        valueChanged = true;
      }
      if (valueChanged) {
        $form = $(this).closest('form');
        formId = $form.attr('id');
        $form.addClass('dirty');
        if (formId in timers) {
          clearTimeout(timers[formId]);
        }
        return timers[formId] = setTimeout(submitForm($form), 750);
      }
    });
    return $(document).on('input propertychange', 'form.edit_record input, form.edit_record textarea', function(e) {
      var $form, formId, valueChanged;
      e.preventDefault();
      valueChanged = false;
      if (e.type === 'propertychange') {
        valueChanged = e.originalEvent.propertyName === 'value';
      } else {
        valueChanged = true;
      }
      if (valueChanged) {
        $form = $(this).closest('form');
        formId = $form.attr('id');
        $form.addClass('dirty');
        if (formId in timers) {
          clearTimeout(timers[formId]);
        }
        return timers[formId] = setTimeout(submitForm($form), 750);
      }
    });
  };

}).call(this);
