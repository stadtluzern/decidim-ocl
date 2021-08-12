// Bug that appears on mobile devices but not on desktop browsers with narrow window width:
// The process navigation (list of components) is open on mobile devices for some reason.
// To work around this, we toggle the navigation collapse state on narrow screens.
$(function() {
  if ($(window).width() < 640) {
    $("#process-nav-content").each((_index, elem) => {
      setTimeout(() => {
        $(elem).trigger('toggle');
      });
    });
  }
})