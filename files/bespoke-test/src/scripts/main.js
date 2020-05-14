// Require Node modules in the browser thanks to Browserify: http://browserify.org
var bespoke = require('bespoke');
var classes = require('bespoke-classes');
var nav = require('bespoke-nav');
var scale = require('bespoke-scale');
var bullets = require('bespoke-bullets');
var hash = require('bespoke-hash');
var prism = require('bespoke-prism');
var multimedia = require('bespoke-multimedia');
var extern = require('bespoke-extern');


// Bespoke.js
var deck = bespoke.from({ parent: 'article.deck', slides: 'section' }, [
    classes(),
    nav(),
    scale('zoom'),
    bullets('.build, .fragment, .build-items > *:not(.build-items)'),
    hash(),
    prism(),
    multimedia(),
    extern(bespoke)
]);

console.log(deck);

// customization


var container = $('article.bespoke-parent');
var slides = $('section.bespoke-slide');
var thm_env = ['theorem', 'corollary', 'definition'];
var scale_ratio = 0.95;


// add ghost-divs
slides.filter(':not(#title-slide)').each(function(){
    $(this).append('<div class="ghost-div"></div>');
});

// reset zoom scale 
// this only works for bespoke-scale with option `zoom`,
// rather than `transform` -- the latter seems do not work well


var rescale = function(ratio) {
    var rescaleAll = function() {
        slides.each(function(i){
            var old_scale = $(this)[0].style.zoom;
            $(this)[0].style.zoom = (old_scale === "" ? ratio : old_scale * ratio);
        });
    };
    window.addEventListener('resize', rescaleAll);
    rescaleAll();
};

rescale(scale_ratio);

document.getElementById('fs').addEventListener('click', () => {
	if (screenfull.enabled) {
		screenfull.request();
	} else {
		// Ignore or do something else
	}
});


// theorem environments
thm_env.forEach(function(element) {
  var env = $('.'+element);
  env.each(function(){
    var credit = $(this).attr("data-credit");
    var tagname = element;
    if (credit === undefined) {
        $(this).prepend('<h4>' + tagname + '</h4>');
    } else {
        $(this).prepend('<h4>' + tagname + ' (' + credit + ')</h4>');
    };
  });
});


// tests

var typedjs = require('typed.js');

var myPlugin = function() {
    return function() {
        deck.on('activate', function(e) {
            console.log('Activated slide ' + (e.index + 1) + ' of ' + deck.slides.length);
        });
    }
};


var typeit = function() {
    return function() {
        deck.on('activate', function(e) {
            console.log('运行');
            var element = '.bespoke-active #typed-strings';
            console.log($(element).length);
            if ($(element).length) {
                var typed = new typedjs('#typed', {
                    stringsElement: element,
                    loop : true
                });
            };
        });
    }
};

bespoke.from('.bespoke-active', [
  myPlugin(),
  typeit(),
]);
