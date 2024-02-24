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
    var checkDirty, error_timers, setTimeoutError, submitForm, timers;
    timers = {};
    error_timers = {};
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
    $(document).on('input propertychange', 'form.edit_record input, form.edit_record textarea', function(e) {
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
        setTimeoutError({
          duration: 10000,
          formId: formId
        });
        if (formId in timers) {
          clearTimeout(timers[formId]);
        }
        return timers[formId] = setTimeout(submitForm($form), 750);
      }
    });
    checkDirty = function(element) {
      if (element.closest('form').classList.contains('dirty')) {
        return toastr.error('You seem to be offline or the server is currently unresponsive. Please ensure your network is operational or try again later.', 'Warning: Error detected!');
      }
    };
    return setTimeoutError = function(params) {
      var duration, element, formId;
      duration = params.duration;
      formId = params.formId;
      element = event.target;
      if (formId in error_timers) {
        clearTimeout(error_timers[formId]);
      }
      return error_timers[formId] = setTimeout(checkDirty.bind(null, element), duration);
    };
  };

}).call(this);
