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
    var scrolltoprocketmeluncur = $('#rocketmeluncur');
    var viewPortHeightrocketmeluncur = parseInt(document.documentElement.clientHeight);
    var scrollHeightrocketmeluncur = parseInt(document.body.getBoundingClientRect().top);
    var basewrocketmeluncur = parseInt(ftrocketmeluncur.clientWidth);
    var swrocketmeluncur = scrolltoprocketmeluncur.clientWidth;
    if (basewrocketmeluncur < 1000) {
        var leftrocketmeluncur = parseInt(fetchOffset(ftrocketmeluncur)['left']);
        leftrocketmeluncur = leftrocketmeluncur < swrocketmeluncur ? leftrocketmeluncur * 2 - swrocketmeluncur : leftrocketmeluncur;
        scrolltoprocketmeluncur.css.left = ( basewrocketmeluncur + leftrocketmeluncur ) + 'px';
    } else {
        scrolltoprocketmeluncur.css.left = 'auto';
        scrolltoprocketmeluncur.css.right = '10px';
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