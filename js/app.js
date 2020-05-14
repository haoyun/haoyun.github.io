// =============================================================================
//   https://clubmate.fi/setting-and-reading-cookies-with-javascript/ 
// =============================================================================

// Create cookie
function createCookie(name, value, days) {
    var expires;
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        expires = "; expires="+date.toGMTString();
    }
    else {
        expires = "";
    }
    document.cookie = name+"="+value+expires+"; path=/";
}

// Read cookie
function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0) === ' ') {
            c = c.substring(1,c.length);
        }
        if (c.indexOf(nameEQ) === 0) {
            return c.substring(nameEQ.length,c.length);
        }
    }
    return null;
}

// Erase cookie
function eraseCookie(name) {
    createCookie(name,"",-1);
}

//==============================================================================
 
 
 
 /*
 /
 / https://codepen.io/Askwithloud/pen/yNRPWB
 /
 / https://ru.stackoverflow.com/questions/685387/fetchoffset-is-not-defined
*/


//ROCKET TO TOP
jQuery(window).scroll(function() {
    if (jQuery(window).scrollTop() < 50) {
        jQuery('#rocketmeluncur').slideUp(500);
    } else {
        jQuery('#rocketmeluncur').slideDown(500);
    }
    var ftrocketmeluncur = jQuery("#ft")[0] ? jQuery("#ft")[0] : jQuery(document.body)[0];
    var scrolltoprocketmeluncur = $('rocketmeluncur');
    var viewPortHeightrocketmeluncur = parseInt(document.documentElement.clientHeight);
    var scrollHeightrocketmeluncur = parseInt(document.body.getBoundingClientRect().top);
    var basewrocketmeluncur = parseInt(ftrocketmeluncur.clientWidth);
    var swrocketmeluncur = scrolltoprocketmeluncur.clientWidth;
    if (basewrocketmeluncur < 1000) {
        var leftrocketmeluncur = parseInt(ftrocketmeluncur.offsetLeft);
        leftrocketmeluncur = leftrocketmeluncur < swrocketmeluncur ? leftrocketmeluncur * 2 - swrocketmeluncur : leftrocketmeluncur;
        scrolltoprocketmeluncur.css('left', (basewrocketmeluncur + leftrocketmeluncur + "px"));
    } else {
        scrolltoprocketmeluncur.css('left', 'auto');
        scrolltoprocketmeluncur.css('right', '10px');
    }
});

jQuery('#rocketmeluncur').click(function() {
    jQuery("html, body").animate({
        scrollTop: '0px',
        display: 'none'
    }, {
        duration: 600,
        easing: 'linear'
    });

    var self = this;
    this.className += ' ' + "launchrocket";
    setTimeout(function() {
        self.className = 'showrocket';
    }, 800);
});


//=============================================================================
//
// https://stackoverflow.com/a/43033380/2929058
//
//=============================================================================

var lang_de = document.querySelectorAll('.lang-de');
var lang_en = document.querySelectorAll('.lang-en');
var lang_cn = document.querySelectorAll('.lang-cn');
var lang_fr = document.querySelectorAll('.lang-fr');
var html_node = document.querySelectorAll('html')[0]

function switch_lang (lang) {
    if (lang == 'de') {
        lang_en.forEach( i => i.style.display = 'none');
        lang_cn.forEach( i => i.style.display = 'none');
        lang_fr.forEach( i => i.style.display = 'none');
        lang_de.forEach( i => i.style.display = 'initial');
        createCookie('user_lang', 'de', 30);
        html_node.setAttribute('lang', 'de');
    }
    if (lang == 'en') {
        lang_de.forEach( i => i.style.display = 'none');
        lang_cn.forEach( i => i.style.display = 'none');
        lang_fr.forEach( i => i.style.display = 'none');
        lang_en.forEach( i => i.style.display = 'initial');
        createCookie('user_lang', 'en', 30);
        html_node.setAttribute('lang', 'en');
    }
    if (lang == 'cn') {
        lang_de.forEach( i => i.style.display = 'none');
        lang_en.forEach( i => i.style.display = 'none');
        lang_fr.forEach( i => i.style.display = 'none');
        lang_cn.forEach( i => i.style.display = 'initial');
        createCookie('user_lang', 'cn', 30);
        html_node.setAttribute('lang', 'zh'); // note it is 'zh'!
    }
    if (lang == 'fr') {
        lang_de.forEach( i => i.style.display = 'none');
        lang_en.forEach( i => i.style.display = 'none');
        lang_cn.forEach( i => i.style.display = 'none');
        lang_fr.forEach( i => i.style.display = 'initial');
        createCookie('user_lang', 'fr', 30);
        html_node.setAttribute('lang', 'fr');
    }
};

function setLanguage () {
    var lang = readCookie('user_lang');
      lang == 'de' ? switch_lang('de')
    : lang == 'en' ? switch_lang('en')
    : lang == 'cn' ? switch_lang('cn')
    : lang == 'fr' ? switch_lang('fr')
    : switch_lang('de');
};

setLanguage();
