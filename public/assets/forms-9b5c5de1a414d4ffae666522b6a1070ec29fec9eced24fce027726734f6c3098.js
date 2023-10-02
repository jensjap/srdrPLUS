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
    return Foundation.Abide.defaults.validators['minimum_length'] = function($el, required, parent) {
      var fieldLength, minimumLength;
      if (!required) {
        return true;
      }
      fieldLength = $el.val().length;
      minimumLength = $el.data('minimumLength');
      if (fieldLength < minimumLength) {
        return false;
      }
    };
  };

}).call(this);
