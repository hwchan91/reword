(function ($) {
  "use strict";
  function centerModal() {
      $(this).css('display', 'block');
      var $dialog  = $(this).find(".modal-dialog"),
      offset       = ($(window).height() - $dialog.height()) / 2,
      bottomMargin = parseInt($dialog.css('marginBottom'), 10);

      // Make sure you don't hide the top part of the modal w/ a negative margin if it's longer than the screen height, and keep the margin equal to the bottom margin of the modal
      if(offset < bottomMargin) offset = bottomMargin;
      $dialog.css("margin-top", offset);
  }

  $(document).on('show.bs.modal', '.modal', centerModal);
  $(window).on("resize", function () {
    if ($(window).width() >= 768 ) {
      $('.modal:visible').each(centerModal);
    }
  });

}(jQuery));

$(document).on('turbolinks:load', function() {
  function centerReorderBtn() {
    offset = $('.curr_word_letter:last-child').offset();
    from_top = Math.round(offset.top);
    from_left = Math.round(offset.left);
    width = $('.curr_word_letter:last-child').width()
    $('.reorder_btn').css('top', from_top + 4);
    $('.reorder_btn').css('left', from_left + width + 16)
  }

  centerReorderBtn();

  $(window).on("resize", function() {
    centerReorderBtn();
    centerDefinition();
  });

  function centerDefinition() {
    offset = $('.curr_word_letter').first().offset();
    from_top = Math.round(offset.top);
    $('.definition').css('top', from_top + 50 );
  }
  centerDefinition();

  $('.next_word_container').click(function() {
    $('.modal').modal('hide');
  })
})