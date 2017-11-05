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
        $('a, .btn').css('pointerEvents', 'none'); //disables the link once clicked
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
        $(this).delay(6500 + index  * 500).fadeIn('slow', function() {
          automaticScroll()
        });
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
      } else {
        $(".achievement").delay(1500).fadeIn(1500);
        $(".next_level_btn_container").delay(3500).fadeIn();
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
      word.hover(function() { 
        toggleDefinition(definition)
      }, function() { 
        toggleDefinition(definition)
      });
    }

    function toggleDefinition(elem) {
      elem.animate({ height: 'toggle', opacity: 'toggle' }, 'slow') 
    }

    function automaticScroll() {
      $("html,body").stop().delay(2000).animate({ scrollTop: $(document).height() }, 'slow');
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
    $(".undo_link").css('pointerEvents', 'none');
  }


  function moveAnimation() {
    if ($("#undo").length == 0) {
      setTimeout(function() {
        if ($(".undo_link").length > 0 ) {
          var undo_link_length = $(".undo_link").length
          var range =  new Array(undo_link_length - 1).join().split(',').map(function(item, index){ return ++index;})
          range.forEach(function(index) {
            $(".last_" + (index + 1) ).addClass("last_" + (index + 2), 500).removeClass("last_" + (index + 1), function() {
            })
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

  
}