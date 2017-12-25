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
