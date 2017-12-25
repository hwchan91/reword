$(document).on('turbolinks:load', function() {
  everyFunction();
})

function togglePlayer() {
  var soundcloud_elem = $('#sc_player')[0];
  var soundcloud_player = SC.Widget(soundcloud_elem);
  soundcloud_player.toggle();
}
