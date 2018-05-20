$(document).on('turbolinks:load', function() {
  everyFunction();
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
