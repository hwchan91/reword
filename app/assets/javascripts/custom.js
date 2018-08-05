$(document).on('turbolinks:load', function() {
  everyFunction();
  firefly();
})

function startPlayer() {
  var soundcloud_elem = $('#sc_player')[0];
  var soundcloud_player = SC.Widget(soundcloud_elem);
  soundcloud_player.play();
}

function pausePlayer() {
  var soundcloud_elem = $('#sc_player')[0];
  var soundcloud_player = SC.Widget(soundcloud_elem);
  soundcloud_player.pause();
}

function skip_zen_level() {
  if ($('#hidden_skip_level_btn_for_video')[0]) {
    $('#hidden_skip_level_btn_for_video')[0].click();
  }
}

function get_hints() {
  if ($('#hidden_get_hints_btn_for_video')[0]) {
    $('#hidden_get_hints_btn_for_video')[0].click();
  }
}

function redirectToPlayStore() {
  if (typeof rate_android_app != 'undefined') {
    $.getScript('/users/update_to_has_rated');
    rate_android_app.go();
  }
}

function disconnected() {
  $('.shield').show();
}

function connected() {
  setTimeout(function() {
    $('.shield').hide();
  }, 10000);
}

function firefly() {
  $.firefly({
    color: '#8be0de',
    minPixel: 3,
    maxPixel: 20,
    total: 0,
    on: 'document.body',
    twinkle: 0,
    borderRadius: 50,
    namespace: 'firefly'
  });
}
