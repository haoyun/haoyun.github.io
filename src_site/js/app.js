 /*
 /
 /
 /
 /
 / captcha-like checkbox
 /
 /
 / https://codepen.io/rynjwssl/pen/XKXYMd
 /
 /
 /
 /
 /
*/

var BOX = $('.captchaBox');
var WRAP = $('.captchaWrapper');
var CONTAINER = $('.captchaContainer');
var CHECK = $('#hiddenCaptcha');

$(function(){
  if(CHECK.prop('checked')) {
    BOX.removeClass();
    BOX.addClass('captchaBox circle fadeOut');
  }
  CONTAINER.click(function() {
    if(CONTAINER.hasClass('captchaError')) {
      CONTAINER.removeClass('captchaError');
    }
  })
});

BOX.click(function() {
  setTimeout(scaleDown, 100);
})
function scaleDown() {
  BOX.addClass('scaleDown');
  setTimeout(scaleUp, 600);
}
function scaleUp() {
  BOX.removeClass('scaleDown boxHover').addClass('circle scaleUp');
  WRAP.addClass('rotation');
  setTimeout(fadeToMark, 1200);
}
function fadeToMark() {
  BOX.removeClass('scaleUp rotation').addClass('fadeOut');
  setTimeout(checkItOut, 400);
}
function checkItOut() {
  CHECK.prop('checked', true);
}