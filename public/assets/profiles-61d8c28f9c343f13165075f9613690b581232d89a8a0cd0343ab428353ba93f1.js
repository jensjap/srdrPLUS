(function() {
  document.addEventListener('DOMContentLoaded', function() {
    if (!($('.profiles').length > 0)) {
      return;
    }
    (function() {
      var escapeRestrictedCharacters, formatResult, formatResultSelection, restrictedCharacters;
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
      $('#profile_degree_ids').select2({
        minimumInputLength: 0,
        ajax: {
          url: '/degrees.json',
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
      $('#profile_organization_id').select2({
        minimumInputLength: 0,
        ajax: {
          url: '/organizations.json',
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
    })();
  });

}).call(this);
