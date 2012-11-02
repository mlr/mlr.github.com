$(function() {
  $('.showmore').on('click', function(e) {
    e.preventDefault();
    target = $('#about');
    open   = (target.height() > 50);
    height = !open ? 354 : 24;
    text   = !open ? "Read Less" : "Read More";
    target.animate({ height: height + 'px' }, 600, 'easeOutBounce');
    $('.showmore').html(text);
  });
});
