(function() {
  document.addEventListener('DOMContentLoaded', function() {
    if (!($('.static_pages').length > 0)) {
      return;
    }
    return (function() {
      var scrollToTop;
      scrollToTop = function() {
        var element, offset, offsetTop;
        element = $('body');
        offset = element.offset();
        offsetTop = offset.top;
        return $('html, body').animate({
          scrollTop: offsetTop
        }, 1000, 'swing');
      };
      $(document).scroll(function() {
        if ($(window).scrollTop() > 100) {
          return $('.scroll-top-wrapper').addClass('show');
        } else {
          return $('.scroll-top-wrapper').removeClass('show');
        }
      });
      $('.scroll-top-wrapper').click(scrollToTop);
      return $('#responsive-menu').on('sticky.zf.stuckto:top', function() {
        $('#signup-link-id').addClass('glow');
      }).on('sticky.zf.unstuckfrom:top', function() {
        $('#signup-link-id').removeClass('glow');
      });
    })();
  });

}).call(this);
