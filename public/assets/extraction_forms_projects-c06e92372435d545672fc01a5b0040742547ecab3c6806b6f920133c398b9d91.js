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
    var post;
    if (!($('.extraction_forms_projects, .extractions').length > 0)) {
      return;
    }
    post = function(path, params, method) {
      var form, hiddenField, key;
      method = method || 'post';
      form = document.createElement('form');
      form.setAttribute('method', method);
      form.setAttribute('action', path);
      for (key in params) {
        if (params.hasOwnProperty(key)) {
          hiddenField = document.createElement('input');
          hiddenField.setAttribute('type', 'hidden');
          hiddenField.setAttribute('name', key);
          hiddenField.setAttribute('value', params[key]);
          form.appendChild(hiddenField);
        }
      }
      document.body.appendChild(form);
      form.submit();
    };
    $('.fill-suggestion').click(function(event) {
      var efpsId, i, inputFields, j, k, len, ref, tableRow, timepoints, tp, tp_elems, type1Desc, type1Name, type1Type;
      if ($(event.target).is('td')) {
        tableRow = $(event.target).closest('tr');
        type1Type = tableRow.children('td[data-t1-type=""]').data('t1-type-id');
        type1Name = tableRow.children('td[data-t1-name=""]').text();
        type1Desc = tableRow.children('td[data-t1-description=""]').text();
        timepoints = [];
        tableRow.find('td[data-timepoints=""] ul li').each(function() {
          return timepoints.push({
            name: $(this).data('tp-name'),
            unit: $(this).data('tp-unit')
          });
        });
        efpsId = $(this).data('sectionId');
        inputFields = $('.new-type1-fields-' + efpsId).last();
        inputFields.find('select[data-t1-type-input=""]').val(type1Type);
        inputFields.find('input[data-t1-name-input=""]').val(type1Name);
        inputFields.find('textarea[data-t1-description-input=""]').val(type1Desc);
        $('#timepoints-node tr').slice(1).each(function() {
          return $(this).find('td.remove-tp-link a').trigger('click');
        });
        if (timepoints.length > 1) {
          for (j = 2, ref = timepoints.length; 2 <= ref ? j <= ref : j >= ref; 2 <= ref ? j++ : j--) {
            $('a.add-timepoint-link').trigger('click');
          }
        }
        tp_elems = $('#timepoints-node tr');
        for (i = k = 0, len = timepoints.length; k < len; i = ++k) {
          tp = timepoints[i];
          $(tp_elems[i]).find('td.tp-name-input input').val(tp['name']);
          $(tp_elems[i]).find('td.tp-unit-input input').val(tp['unit']);
        }
        return $(this).closest('.reveal').foundation('close');
      }
    });
    $('input.select-all[type="checkbox"]').click(function(e) {
      var that;
      that = $(this);
      return that.closest('table').find('input.quality-dimension-select').prop('checked', that.is(':checked'));
    });
    $('#submit-quality-dimensions').click(function(e) {
      var a_qdqId, csrfToken, efpsId;
      a_qdqId = [];
      efpsId = $(this).data('extraction-forms-projects-section-id');
      csrfToken = $('meta[name="csrf-token"]').attr('content');
      $('input.quality-dimension-select:checkbox:checked').each(function() {
        var qdqId, that;
        that = $(this);
        qdqId = that.attr('id');
        return a_qdqId.push(qdqId);
      });
      if (!Array.isArray(a_qdqId) || !a_qdqId.length) {
        return $('#modal-' + efpsId).foundation('close');
      } else {
        $('#modal-' + efpsId).html('Submitting..');
        return post('/extraction_forms_projects_sections/' + efpsId + '/add_quality_dimension', {
          a_qdqId: a_qdqId,
          authenticity_token: csrfToken
        });
      }
    });
    $('#extraction_forms_projects_section_extraction_forms_projects_sections_type1s_attributes_0_timepoint_name_ids').select2({
      minimumInputLength: 0
    });
    $('#extraction_forms_projects_sections_type1_timepoint_name_ids').select2({
      minimumInputLength: 0
    });
    return $(document).on("click", ".radio-deselector-btn", function(e) {
      var dataRadioRemoveId, radioElements;
      dataRadioRemoveId = $(e.target).data('radio-remove-id');
      radioElements = $("*[data-radio-remove-id='" + dataRadioRemoveId + "']");
      radioElements.removeAttr('checked');
      $(radioElements[0]).trigger("change");
      return $(radioElements[0]).trigger("input");
    });
  };

}).call(this);
