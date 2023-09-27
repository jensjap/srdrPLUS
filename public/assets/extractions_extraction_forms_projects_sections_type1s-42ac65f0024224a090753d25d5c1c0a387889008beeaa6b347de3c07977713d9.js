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
    var formatTimepoint, formatTimepointSelection;
    if (!($('.extractions_extraction_forms_projects_sections_type1s').length > 0)) {
      return;
    }
    $('.edit_extractions_extraction_forms_projects_sections_type1 .add_fields').data('association-insertion-method', 'append').data('association-insertion-node', function(link) {
      return link.closest('#populations, #timepoints').find('tbody');
    });
    formatTimepoint = function(timepoint) {
      var markup;
      if (timepoint.loading) {
        return timepoint.text;
      }
      markup = '<div class="select2-timepoint" style="border: 1px solid grey; border-radius: 10px; padding: 5px;">';
      markup += '  <div class="select2-timepoint__name">Name: ' + timepoint.text + '</div>';
      if (timepoint.unit) {
        markup += '  <div class="select2-timepoint__unit">Unit: ' + timepoint.unit + '</div>';
      } else {
        markup += '  <div class="select2-timepoint__unit">Unit: </div>';
      }
      markup += '</div>';
      return markup;
    };
    formatTimepointSelection = function(timepoint) {
      return timepoint.text;
    };
    return $('#extractions_extraction_forms_projects_sections_type1_row_timepoint_name_id').select2({
      minimumInputLength: 0,
      closeOnSelect: true,
      ajax: {
        url: '/api/v1/timepoint_names',
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
                unit: i.unit
              };
            })
          };
        },
        cache: true
      },
      placeholder: 'Search for an existing Timepoint',
      escapeMarkup: function(markup) {
        return markup;
      },
      templateResult: formatTimepoint,
      templateSelection: formatTimepointSelection
    }, $(".dropdown_with_writein").select2({
      tags: true,
      multiple: true,
      maximumSelectionLength: 1
    }));
  };

}).call(this);
