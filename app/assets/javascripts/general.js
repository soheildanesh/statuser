
//for token input autocomplete///// 		
$( document ).ready(
	function() {
	$(".personInput").tokenInput("/person");
});
//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".personInput", function() {
  	$(".personInput").tokenInput("/person");
});



$( document ).ready(
	function() {
	$(".siteidInput").tokenInput("/site");
});
$( document ).on( "focus", ".siteidInput", function() {
  	$(".siteidInput").tokenInput("/site");
});



$( document ).ready(
	function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
$( document ).on( "focus", ".siteTask", function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
///////////////////////////////////



