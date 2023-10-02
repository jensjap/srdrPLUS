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
    var filterProjectList, formatMeSHDescriptor;
    if (!($('.projects, .citations, .extractions, .build').length > 0)) {
      return;
    }
    filterProjectList = function(order) {
      return function() {
        $.get({
          url: '/projects/filter?q=' + $('#project-filter').val() + '&o=' + order,
          dataType: 'script'
        });
      };
    };
    $('#project-filter').keyup(function(e) {
      var currentOrder;
      e.preventDefault();
      currentOrder = $('.toggle-sort-order button.button.active').data('sortOrder');
      delay(filterProjectList(currentOrder), 750);
    });
    $('.toggle-sort-order button').mousedown(function(e) {
      var nextOrder;
      e.preventDefault();
      if ($(this).hasClass('active')) {
        return;
      }
      nextOrder = $('.toggle-sort-order button.button.disabled').data('sortOrder');
      filterProjectList(nextOrder)();
    });
    $('button.search').mousedown(function(e) {
      e.preventDefault();
      $('.search-field').toggleClass('expand-search');
      $('#project-filter').focus();
    });
    $('.export-type-radio').each(function(e) {
      var export_button, link_string;
      if ($(this).is(':checked')) {
        export_button = $(this).parents('.export-type-selection').find('.start-export-button');
        return link_string = $(export_button).attr('href', $(this).val());
      }
    });
    $('.export-type-radio').on('change', function(e) {
      var export_button, link_string;
      if ($(this).is(':checked')) {
        export_button = $(this).parents('.export-type-selection').find('.start-export-button');
        return link_string = $(export_button).attr('href', $(this).val());
      }
    });
    if ($('body.projects.new').length === 1) {
      $('#projects-users-container').on('cocoon:after-insert', function(_, projectsUsersElem) {
        return $(projectsUsersElem).on('cocoon:after-insert', function(_, insertedElem) {
          var $new_kq_input, $source_kq_input;
          $(insertedElem).find('.distiller-section-input').select2({
            placeholder: "-- Select Section --",
            tags: true
          });
          $new_kq_input = $(insertedElem).find('.distiller-key-question-input');
          if ($('.distiller-section-file-container select.distiller-key-question-input').length > 1) {
            $source_kq_input = $('.distiller-section-file-container select.distiller-key-question-input').first();
            $source_kq_input.find('option').each(function(_, kq_option) {
              var $kq_option;
              $kq_option = $(kq_option);
              if ($new_kq_input.find('option[value="' + $kq_option.val() + '"]').length === 0) {
                $new_kq_input.append(new Option($kq_option.val(), $kq_option.val(), false, false));
              }
              return $new_kq_input.trigger('change');
            });
          }
          return $new_kq_input.select2({
            placeholder: "-- Select Key Question --",
            tags: true
          }).on('change', function(e) {
            var $isNew;
            $isNew = $(this).find('[data-select2-tag="true"]');
            if ($isNew.length && $isNew.val() === $(this).val()) {
              return $('.distiller-section-file-container select.distiller-key-question-input').each(function(_, kq_input) {
                var $kq_input;
                $kq_input = $(kq_input);
                if ($kq_input.find('option[value="' + $isNew.val() + '"]').length === 0) {
                  $kq_input.append(new Option($isNew.val(), $isNew.val(), false, false)).trigger('change');
                }
                return $isNew.replaceWith(new Option($isNew.val(), $isNew.val(), false, true));
              });
            }
          });
        });
      });
      $('#create-type').on('change', function(e) {
        $('.input.file input').val('');
        if ($(e.target).val() === "empty") {
          $('.remove-projects-user').trigger("click");
          $('.submit').removeClass('hide');
          return $('.submit-with-confirmation').addClass('hide');
        } else if ($(e.target).val() === "distiller") {
          $('#add-projects-user').trigger("click");
          $('#distiller-add-references-file').trigger("click");
          $('#distiller-add-section-file').trigger("click");
          $('.submit').addClass('hide');
          return $('.submit-with-confirmation').removeClass('hide');
        } else if ($(e.target).val() === "json") {
          $('.submit').addClass('hide');
          return $('.submit-with-confirmation').removeClass('hide');
        }
      });
    }
    if ($('body.projects.edit').length === 1) {
      $(".project_projects_users_user select").select2({
        minimumInputLength: 0,
        ajax: {
          url: '/api/v1/users.json',
          dataType: 'json',
          delay: 100,
          data: function(params) {
            return {
              q: params.term,
              page: params.page || 1
            };
          }
        }
      });
      $('#projects-users-table').on('cocoon:after-insert', function(e, insertedItem) {
        return $(insertedItem).find('.project_projects_users_user select').select2({
          minimumInputLength: 0,
          ajax: {
            url: '/api/v1/users.json',
            dataType: 'json',
            delay: 100,
            data: function(params) {
              return {
                q: params.term,
                page: params.page || 1
              };
            }
          }
        });
      });
    }
    $('.projects.edit').find('#project_method_description_select2').select2({
      tags: true,
      allowClear: true,
      placeholder: '-- Select or type other --'
    });
    formatMeSHDescriptor = function(result) {
      var markup;
      if (result.loading) {
        return result.text;
      }
      markup = '<div class="select2-mesh-descriptor-search-result">';
      markup += '<span>';
      markup += result.text;
      markup += '</span>';
      markup += '<br />';
      markup += '<span>';
      markup += '<a href="' + result.resource + '" target="_blank" data-confirm="' + gon.exit_disclaimer + '">Link to NLM MeSH Descriptor</a>';
      markup += '</span>';
      markup += '</div>';
      return markup;
    };
    return $('.projects.edit').find('#project_mesh_descriptor_ids').select2({
      ajax: {
        delay: 500,
        url: "/api/v2/mesh_descriptors.json",
        dataType: "json",
        data: function(params) {
          return {
            q: params.term,
            page: params.page || 1,
            per_page: params.per_page || 10
          };
        }
      },
      minimumInputLength: 1,
      closeOnSelect: false,
      allowClear: true,
      templateResult: formatMeSHDescriptor,
      escapeMarkup: function(markup) {
        return markup;
      }
    });
  };

}).call(this);
