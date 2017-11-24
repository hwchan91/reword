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
        $('a, .btn, .options_btn').css('pointerEvents', 'none'); //disables the link once clicked
        $('.reorder_btn').off();
        $('.modal-backdrop').fadeOut("fast");
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
    function closeLevelAnimation() {
      var to_fade = ["#start", "#target", ".history", ".definition", ".limit_count"];
      to_fade.forEach(function(elem_to_fade) {
        $(elem_to_fade).fadeOut(3000);
      });
      $(".curr_word_letter").addClass("complete", 3000);

      var panes = [".start_word", ".target_word"];
      panes.forEach(function(pane) {
        $(pane).delay(2500).animate({height: "50%"},2000);
      })
      setTimeout(hideEverything, 4500)
      setTimeout(function() {
        var background_color = $('.start_word').css("backgroundColor")
        $("body").css("background", background_color )
        $(".message_container").show();
      },4500)
    }
    closeLevelAnimation();

    function animateMessage() { 
      $("#completed_in").delay(5500).fadeIn('fast');
      $("#path_length").delay(6000).fadeIn('slow');
      $(".path_word_container").each(function(index) {
        var self = $(this);
        setTimeout(function() {
          self.fadeIn('slow', function() {
            automaticScroll();
          })
        }, 6500 + index * 500)
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
        
      }, 8500 + $(".path_word_container").length * 500 )
    }
    hideDefinitionThenShowButton();

    function fadeInPlayAgain() {
      if ($(".achievement").length == 0) {
        $(".next_level_btn_container").delay(500).fadeIn();
        $("html,body").stop().delay(0).animate({ scrollTop: $(document).height() }, 'slow');
      } else {
        $(".achievement").delay(1500).fadeIn(1500);
        $(".next_level_btn_container").delay(2500).fadeIn();
        $("html,body").stop().delay(3500).animate({ scrollTop: $(document).height() }, 'slow');
      }
    }

    function enableDisplayDefinitionWhenHover() {
      setTimeout(function() {
        $(".path_word").each(function() {
          displayDefinitionWhenHover(this)
        })
      }, 9000 + $(".path_word_container").length * 500 )
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
      $("html,body").stop().delay(0).animate({ scrollTop: $(document).height() }, 'slow');
    }

    function gradientHighlightLetter() {
      $(".highlight").each(function(index) {
        var highlight_color = window.getComputedStyle(document.documentElement).getPropertyValue('--complete-highlight-color');
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
        if ($(".undo_link").length > 0 ) {
          var undo_link_length = $(".undo_link").length
          var range =  new Array(undo_link_length - 1).join().split(',').map(function(item, index){ return index++;})
          range.forEach(function(index) {
            $(".last_" + (index + 1) ).addClass("last_" + (index + 2), 500)//.removeClass("last_" + (index + 1))
          })
        }
        $(".last_0").addClass("last_1").fadeIn(500).removeClass("last_0");
      }, 1000)

      $(".last_5").delay(1000).slideUp(500).fadeOut(500);
    } 

    setTimeout(function() {
      $(".curr_word_container").animate({opacity: "1"}, 500);
    }, 1000);

    $(".next_word").click(function() {
      $(".curr_word_container").fadeOut(1500);
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
    $(".level_start_word").lettering();
    $(".level_target_word").lettering();
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
      $('html, body').delay(500).animate({scrollTop: top_offset}, "slow")
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

  $('#start').lettering();
  $('#target').lettering();

  $('.select_level_btn').click(function() {
    $('.content>div').fadeOut('fast');
  })


  $('.send_email').click(function (event) {
    var email = 'wordlinkthegame@gmail.com';
    var subject = 'Comments on Word Link';
    var emailBody = 'Hi, here are my comments on Word Link:';
    document.location = "mailto:"+email+"?subject="+subject+"&body="+emailBody;
  });

  $('.credits_btn').click(function() {
    $('.credits_content').show();
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

  //prevent overscrolling
  var selScrollable = '.scrollable';
  // Uses document because document will be topmost level in bubbling
  $(document).on('touchmove',function(e){
    e.preventDefault();
  });
  // Uses body because jQuery on events are called off of the element they are
  // added to, so bubbling would not work if we used document instead.
  $('body').on('touchstart', selScrollable, function(e) {
    if (e.currentTarget.scrollTop === 0) {
      e.currentTarget.scrollTop = 1;
    } else if (e.currentTarget.scrollHeight === e.currentTarget.scrollTop + e.currentTarget.offsetHeight) {
      e.currentTarget.scrollTop -= 1;
    }
  });
  // Stops preventDefault from being called on document if it sees a scrollable div
  $('body').on('touchmove', selScrollable, function(e) {
    e.stopPropagation();
  });

}