$(document).on('turbolinks:load', function() {
  everyFunction();
})


var soundcloud_elem = $('#sc_player')[0];
var soundcloud_player = SC.Widget(soundcloud_elem);

function startPlayer() {
  soundcloud_player.play();
}

function pausePlayer() {
  soundcloud_player.pause();
}
