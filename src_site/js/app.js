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
  $('.c-checkbox-4').addClass("c-checkbox-checkmark");//.delay(3000).queue(function() {
  //  $('.c-checkbox-5').addClass("c-checkbox-checked");
  //});
  $('#to-activate-1').contents().unwrap().wrapAll("<a href='/s/'></a>");
  $('#to-activate-1').contents().unwrap().wrapAll("<a href='/n/'></a>");
});