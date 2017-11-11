 /*
 /
 / replace div 
 / have to use JS as the text is parsed by Pandoc
 /
*/



$("span#to-replace-1").replaceWith('\
<div style="\
display: inline-block;\
height: 3rem;\
margin-top: -3rem;\
width: 80%;\
margin-left: -80%;\
left: 80%;\
top: 1.5rem;\
z-index: -1;\
position: relative;\
background: url(/images/unqualified.png) no-repeat;\
background-size: auto 3rem;\
opacity:.6;"></div>'); 

$("span#to-replace-2").replaceWith('\
<div style="\
display: inline-block;\
height: 3rem;\
margin-top: -3rem;\
width: 30%;\
margin-left: -40%;\
left: 30%;\
top: .5rem;\
z-index: -1;\
position: relative;\
background: url(/images/stupid.png) no-repeat;\
background-size: 5rem auto;\
opacity:.7;"></div>');


 /*
 /
 / fake recaptcha
 /
 /
*/

var c_container = $(".c-container");

c_container.click(function() {
    $('.c-checkbox-0').remove();
    $('.c-checkbox-1').addClass("c-checkbox-borderAnimation-33");
    $('.c-checkbox-3').addClass("c-checkbox-spinnerAnimation");
    $('.c-checkbox-2').addClass("c-checkbox-spinner");
    $('.c-checkbox-4').addClass("c-checkbox-checkmark").delay(3000).queue(function() {
        $('#to-activate-1').contents().unwrap().wrapAll("<a href='/s/'></a>");
        $('#to-activate-2').contents().unwrap().wrapAll("<a href='/n/'></a>");   
    });
});



 /*
 /
 / https://codepen.io/Askwithloud/pen/yNRPWB
 /
 /
*/


jQuery(window).scroll(function(){
    if(jQuery(window).scrollTop()<50){
        jQuery('#rocketmeluncur').slideUp(500);
    }else{
        jQuery('#rocketmeluncur').slideDown(500);
    }
    var ftrocketmeluncur = jQuery("#ft")[0] ? jQuery("#ft")[0] : jQuery(document.body)[0];
    var scrolltoprocketmeluncur = $('#rocketmeluncur');  // the original without #
    var viewPortHeightrocketmeluncur = parseInt(document.documentElement.clientHeight);
    var scrollHeightrocketmeluncur = parseInt(document.body.getBoundingClientRect().top);
    var basewrocketmeluncur = parseInt(ftrocketmeluncur.clientWidth);
    var swrocketmeluncur = scrolltoprocketmeluncur.clientWidth;
    if (basewrocketmeluncur < 1000) {
        var leftrocketmeluncur = parseInt(fetchOffset(ftrocketmeluncur)['left']);
        leftrocketmeluncur = leftrocketmeluncur < swrocketmeluncur ? leftrocketmeluncur * 2 - swrocketmeluncur : leftrocketmeluncur;
        scrolltoprocketmeluncur.css.left = ( basewrocketmeluncur + leftrocketmeluncur ) + 'px';  // the original was .style.left
    } else {
        scrolltoprocketmeluncur.css.left = 'auto';  // the original was .style.left
        scrolltoprocketmeluncur.css.right = '10px';  // the original was .style.left
    }
});

jQuery('#rocketmeluncur').click(function(){
    jQuery("html, body").animate({ scrollTop: '0px',display:'none'},{
            duration: 600,  
            easing: 'linear'
        });
    
    var self = this;
    this.className += ' '+"launchrocket";
    setTimeout(function(){
      self.className = 'showrocket';
    },800)
});



/*!
* FitText.js 1.2
*
* Copyright 2011, Dave Rupert http://daverupert.com
* Released under the WTFPL license
* http://sam.zoy.org/wtfpl/
*
* Date: Thu May 05 14:23:00 2011 -0600
*/

(function( $ ){

  $.fn.fitText = function( kompressor, options ) {

    // Setup options
    var compressor = kompressor || 1,
        settings = $.extend({
          'minFontSize' : Number.NEGATIVE_INFINITY,
          'maxFontSize' : Number.POSITIVE_INFINITY
        }, options);

    return this.each(function(){

      // Store the object
      var $this = $(this);

      // Resizer() resizes items based on the object width divided by the compressor * 10
      var resizer = function () {
        $this.css('font-size', Math.max(Math.min($this.width() / (compressor*10), parseFloat(settings.maxFontSize)), parseFloat(settings.minFontSize)));
      };

      // Call once to set.
      resizer();

      // Call on resize. Opera debounces their resize by default.
      $(window).on('resize.fittext orientationchange.fittext', resizer);

    });

  };

})( jQuery );

jQuery(".responsive_huge_text").fitText(.1);
