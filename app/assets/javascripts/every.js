function everyFunction() {

  function centerModal() {
    $(this).css('display', 'block');
    var $dialog  = $(this).find(".modal-dialog"),
    offset       = ($(window).height() - $dialog.height()) / 2,
    bottomMargin = parseInt($dialog.css('marginBottom'), 10);

    // Make sure you don't hide the top part of the modal w/ a negative margin if it's longer than the screen height, and keep the margin equal to the bottom margin of the modal
    if (offset < bottomMargin) {
      offset = bottomMargin;
    }
    $dialog.css("margin-top", offset);
  }

  $(document).on('show.bs.modal', '.modal', centerModal);
  $(window).on("resize", function () {
    if ($(window).width() >= 768 ) {
      $('.modal:visible').each(centerModal);
    }
  });

  function openReorderModal() {
    $('.reorder_btn').on('click', showReorderModal)
  }
  openReorderModal();

  function showReorderModal(event) {
    event.stopPropagation();
    $("#reorder_letters").modal("show");
  }

  function clickAndDisable() {
    $('a').each(function() {
      $(this).click(function(event) {
        if (navigator.onLine && event.target.id !== 'hidden_get_hints_btn_for_video' && event.target.id !== 'soundcloud_link') {
          $('a, .btn, .options_btn').css('pointerEvents', 'none'); //disables the link once clicked
          $('.reorder_btn').off();
          $('.modal-backdrop').fadeOut("fast");
        }
      })
    });
  }
  clickAndDisable();


  function closeModalWhenClickedOutside() {
    $('.next_word_container').click(function() {
        $('.modal').modal('hide');
    })
  }
  closeModalWhenClickedOutside();


  function endingAnimation() {
    var time_to_close = 1500
    function closeLevelAnimation() {
      var to_fade = ["#start", "#target", ".history", ".definition", ".limit_count"];
      to_fade.forEach(function(elem_to_fade) {
        $(elem_to_fade).fadeOut(time_to_close);
      });
      $(".curr_word_letter").addClass("complete", time_to_close);

      var panes = [".start_word", ".target_word"];
      panes.forEach(function(pane) {
        $(pane).delay(1000).animate({height: "50%"},500);
      })
      setTimeout(hideEverything, time_to_close)
      setTimeout(function() {
        //var background_color = $('.start_word').css("backgroundColor")
        //$("body").css("background", background_color )
        $(".message_container").show();
        $('.firefly').hide();
      },time_to_close)
    }
    closeLevelAnimation();

    function animateMessage() {
      $("#completed_in").delay(time_to_close + 500).fadeIn('fast');
      $("#path_length").delay(time_to_close + 1000).fadeIn('slow');
      $(".path_word_container").each(function(index) {
        var self = $(this);
        setTimeout(function() {
          self.fadeIn('slow', function() {
            automaticScroll();
          })
        }, (time_to_close + 1000) + index * 200)
      })
    }
    animateMessage();

    function hideEverything() {
      $('.content > div').each(function() {
        if ( !$(this).hasClass("message_container") ) {
          $(this).hide();
        }
      });
    }

    function hideDefinitionThenShowButton() {
      setTimeout(function() {
        toggleDefinition($(".path_word_definition"));
        fadeInPlayAgain();

      }, (time_to_close + 2000) + $(".path_word_container").length * 200 )
    }
    hideDefinitionThenShowButton();

    function fadeInPlayAgain() {
      if ($(".achievement").length == 0) {
        $(".next_level_btn_container").delay(1000).fadeIn();
        $(".content").stop().delay(1000).animate({ scrollTop: $('.message_container').height() + 500 }, 'slow', showRateDialog);
        $("#message_footer_orb").delay(1500).fadeIn();
      } else {
        $(".achievement").delay(1000).fadeIn(500);
        $(".next_level_btn_container").delay(2000).fadeIn();
        $(".content").stop().delay(1500).animate({ scrollTop: $('.message_container').height() + 500 }, 'slow', showRateDialog);
        $("#message_footer_orb").delay(2000).fadeIn();
      }
    }

    function showRateDialog() {
      if ($('#rate_dialog_overlay')[0] && typeof rate_android_app != 'undefined') {
        $('#rate_dialog_overlay').modal("show");
      }
    }

    function enableDisplayDefinitionWhenHover() {
      setTimeout(function() {
        $(".path_word").each(function() {
          displayDefinitionWhenHover(this)
        })
      }, (time_to_close + 4000)+ $(".path_word_container").length * 200 )
    }
    enableDisplayDefinitionWhenHover();

    function displayDefinitionWhenHover(that) {
      var word = $(that)
      var definition = word.next(".path_word_definition")
      word.click(function() {
        toggleDefinition(definition)
      });
    }

    function toggleDefinition(elem) {
      elem.animate({ height: 'toggle', opacity: 'toggle' }, 'slow')
    }

    function automaticScroll() {
      $(".content").stop().animate({ scrollTop: $('.message_container').height() }, 'slow');
    }

    function gradientHighlightLetter() {
      $(".highlight").each(function(index) {
        var highlight_color = $('#highlight_color_setter').css('color');
        highlight_color = getRGB(highlight_color);

        var red = Number(highlight_color.red) + index * 2
        if (red > 255) {
          red = 255
        }
        var green = Number(highlight_color.green) - index * 2
        if (green < 0) {
          green = 0
        }
        var blue = Number(highlight_color.blue) - index * 10
        if (blue < 0) {
          blue = 0
        }

        $(this).css("color", "rgb(" + red + ", " + green  +", " + blue + ")")
      })
    }
    gradientHighlightLetter();
  }

  function getRGB(str){
    var match = str.match(/rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/);
    return match ? {
      red: match[1],
      green: match[2],
      blue: match[3]
    } : {};
  }

  if ($("#level_complete").length > 0) {
    disableBackLinks();
    setTimeout(function() {
      endingAnimation();
    }, 2000);
  };

  function disableBackLinks() {
    $(".undo_link").each(function() {
     $(this).css('pointer-events', 'none');
     $(this).css('cursor', 'default');
    })
  }


  function moveAnimation() {
    if ($("#undo").length == 0) {
      setTimeout(function() {
        if ($(".prev_moves").length > 0 ) {
          var undo_link_length = $(".prev_moves").length
          var range =  new Array(undo_link_length - 1).join().split(',').map(function(item, index){ return index++;})
          range.forEach(function(index) {
            $(".last_" + (index + 1) ).addClass("last_" + (index + 2), 200).removeClass("last_" + (index + 1))
          })
        }
        $(".last_0").addClass("last_1").fadeIn(200).removeClass("last_0");
      }, 200)

      //$(".last_4").delay(1000).hide();
      // $(".prev_moves").first().hide(2000);
    }

    setTimeout(function() {
      $(".curr_word_container").animate({opacity: "1"}, 500);
    }, 200);

    $(".next_word").click(function() {
      $(".curr_word_container").fadeOut(1000);
    })
  }
  moveAnimation();


  $(".music_btn, .music_row").click(function(e) {
    e.stopPropagation();
    togglePlayer();
    checkIfMusicPlaying();
  })

  function togglePlayer() {
    var soundcloud_elem = $('#sc_player')[0];
    var soundcloud_player = SC.Widget(soundcloud_elem);
    soundcloud_player.toggle();
  }

  function checkIfMusicPlaying() {
    var soundcloud_elem = $('#sc_player')[0];
    var soundcloud_player = SC.Widget(soundcloud_elem);
    var btn = $('.music_btn').children('.glyphicon')
    soundcloud_player.isPaused(function(e) {
      if (e) {
        btn.addClass('glyphicon-volume-off');
        btn.removeClass('glyphicon-volume-up');
      } else {;
        btn.addClass('glyphicon-volume-up');
        btn.removeClass('glyphicon-volume-off');
      }
    })
  }
  if ( $('.starting_page').length == 0 ) {
    checkIfMusicPlaying();
  }


  //level selection page functions
  function addSpanAroundLetters() {
    $(".level_start_word:not(.level_selection_row)").lettering();
    $(".level_target_word:not(.level_selection_row)").lettering();
  }
  addSpanAroundLetters();

  function goToLevel() {
    $('.level_btn').click(function() {
      var $self = $(this)
      var $level = $self.parent('.level')
      if (!$self.hasClass("loading") && ( $level.hasClass('completed_level') || $level.prev('.level').hasClass('completed_level') || $level.prev().hasClass('chapter')   ) ) {
        var level = $level.data('level')
        var $start = $level.children('.level_start_word')
        var $target = $level.children('.level_target_word')

        if (!$start.is(':visible')) {
          $('.level_start_word').fadeOut('slow');
          $('.level_target_word').fadeOut('slow');
          $start.fadeIn('slow');
          $target.fadeIn('slow');
        } else {
          $('.level_btn').addClass("loading");
          $.getScript('/levels/' + level);
          $('.level_selection_page').fadeOut(1000);
        }
      }


    })
  }
  goToLevel();

  function scrollToLatestLevel() {
    var incomplete_levels = $('.level:not(.completed_level)')
    if (incomplete_levels.length > 0 ) {
      var window_height = $(window).height();
      var top_offset = incomplete_levels.first().offset().top + incomplete_levels.first().height() / 2 - window_height / 2
      $('.content').delay(500).animate({scrollTop: top_offset}, "slow")
    }
  }
  scrollToLatestLevel();

  $(".options").click(function() {
    $(".options_overlay").css("display", "flex");
  })

  $(".back_btn").click(function() {
    if ($('.default_content').is(":visible")) {
      $(".options_overlay").css("display", "none");
    } else {
      $('.credits_content').hide();
      $('.profile_content').hide();
      $('.default_content').show();
    }
  });

  //seems soundcloud takes a while to load, which may cause this function to not work
  setTimeout(function() {
    $('body').click(function() {
      if (!$('body').hasClass("music_started")) {
        var soundcloud_elem = $('#sc_player')[0];
        var soundcloud_player = SC.Widget(soundcloud_elem);
        soundcloud_player.play();
        checkIfMusicPlaying();
        $('body').addClass("music_started")
      }
    })
  }, 1000);

  $('.select_level_btn, .to_menu_btn').click(function() {
    if (navigator.onLine) {
      $('.content>div').fadeOut('fast');
    }
  })

  $('.skip_level_btn').click(function() {
    if (navigator.onLine) {
      if (typeof reward_display !== 'undefined') {
        display_video_ad();
      } else {
        $('.content>div').fadeOut('fast');
        $('#hidden_skip_level_btn')[0].click();
      }
    }
  })

  function display_video_ad() {
    reward_display.performClick();
  }

  $('#want_hints, #more_hints').click(function() {
    if (navigator.onLine) {
      display_video_ad();
    }
  })

  $('.send_email').click(function (event) {
    var email = 'rewordthegame@gmail.com';
    var subject = 'Comments on REWORD';
    var emailBody = 'Hi, here are my comments on REWORD:';
    document.location = "mailto:"+email+"?subject="+subject+"&body="+emailBody;
  });

  $('.credits_btn').click(function() {
    $('.credits_content').show();
    $('.default_content').hide();
  })

  $('.profile_btn').click(function() {
    $('.profile_content').show();
    $('.default_content').hide();
  })

  function loopSoundcloud() {
    var soundcloud_elem = $('#sc_player')[0];
    var soundcloud_player = SC.Widget(soundcloud_elem);
    soundcloud_player.bind(SC.Widget.Events.FINISH, function() {
      soundcloud_player.seekTo(0);
      soundcloud_player.play();
    });
  }
  loopSoundcloud();

  function blinkPreviousWhenNoChoices() {
    if($('.no_moves_left').length > 0) {
      $('.history').addClass('blink')
    }
  }
  blinkPreviousWhenNoChoices();


  function disableWordBtnsWhenNoChoicesOrComplete() {
    if($('.no_moves_left').length > 0 || $('#level_complete').length > 0) {
      $('.curr_word_letter').css('pointer-events', 'none');
    }
  }
  disableWordBtnsWhenNoChoicesOrComplete();


  // tutorial
  var level_no = $('.hidden').data('level_no');
  var hint = $('.hidden').data('hint');
  if($('.prev_moves').length == 0 && hint) {
   hint.forEach(function(i) {
      if(i == -1) {
        blinkReorderBtn() ;
      } else {
        flash(i)
      }
   })
  }

  if (level_no <= 10) {
    hideReorderBtn();
  }


  function flash(index) {
    $($('.curr_word_letter')[index]).addClass('hint');
  }

  function blinkReorderBtn() {
    $('.reorder_btn').addClass('blink');
  }

  function hideReorderBtn() {
    $('.reorder_btn').hide();
  }

  $('.prev_moves').on('click', function(e) {
    var step_no = $(this).attr('class').match(/\d/)[0];
    while (step_no > 0) {
      $('.last_' + step_no).slideDown(500).fadeOut(500);
      step_no = step_no -1;
    }
    $(".curr_word_container").animate({opacity: "0"}, 500);
  })

  function clickSkipZenAndDisable() {
    $('.skip_Level_btn').click(function() {
      $('.modal-backdrop').fadeOut(1000);
    });
  }
  clickSkipZenAndDisable();

  // $('body, a, div, span').on('click', function(e) {
  //   toggleShield(e)
  // });

  // function toggleShield(e) {
  //   if(!navigator.onLine) {
  //     e.preventDefault();
  //     e.stopPropagation();
  //     $('.shield').show();
  //   }
  //   else {
  //     $('.shield').hide();
  //   }
  // }

  function showHints() {
    $('#show_hints_btn').click(function() {
      $('#options_overlay').modal('hide');
    })
  }
  showHints();

  function checkIfHasVideoAd() {
    if (typeof reward_display == 'undefined') {
      $('.hints_related').remove();
    }
  }
  checkIfHasVideoAd();

  for (i = 1; i < 7; i++) {
    level_orb_bob(i);
    level_orb_eyes_gaze(i);
  }
  level_sleeping_orb_blink();
  level_complete_orb_finale();
  title_orb_bob();
  title_orb_eyes_gaze();
  message_footer_orb_eyes_gaze();

  function level_orb_bob(i) {
    var level_orb = anime({
      targets: '.orb-' + String(i),
      translateY: anime.random(-20,-70),
      scale: 1.1,
      opacity: Math.random() * 0.3 + 0.2,
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        level_orb.restart();
      }
    });
  }

  function level_orb_eyes_gaze(i) {
    var level_orb_eyes = anime({
      targets: '.orb_eyes-' + String(i),
      translateY: anime.random(-5,5),
      translateX: anime.random(-5,5),
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        level_orb_eyes.restart();
      }
    });
  }

  function level_sleeping_orb_blink() {
    var level_sleeping_orb = anime({
      targets: '.sleeping_orb',
      opacity: 0.1,
      scale: 0.5,
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        level_sleeping_orb.restart();
      }
    });
  }

  function level_complete_orb_finale() {
    var level_complete_orb = anime({
      targets: '.complete_orb',
      translateY: '-70',
      scale: 1.1,
      opacity: 1,
      duration: 2000,
    });
  }

  function title_orb_bob() {
    var title_orb = anime({
      targets:  '.title_orb',
      translateY: anime.random(-20,-70),
      scale: 1.1,
      opacity: Math.random() * 0.3 + 0.7,
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        title_orb.restart();
      }
    });
  }

  function title_orb_eyes_gaze() {
    var title_orb_eyes = anime({
      targets: '.title_orb_eyes',
      translateY: anime.random(-10,10),
      translateX: anime.random(-10,10),
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        title_orb_eyes.restart();
      }
    });
  }

  function message_footer_orb_eyes_gaze() {
    var footer_orb_eyes = anime({
      targets: '.message_footer_orb_eyes',
      translateY: anime.random(-20,20),
      translateX: anime.random(-20,20),
      duration:  function() { return anime.random(1000, 3000); },
      delay: 0,
      direction: 'alternate',
      elasticity: 300,
      complete: function(anim) {
        footer_orb_eyes.restart();
      }
    });
  }







}
