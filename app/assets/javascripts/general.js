		
$( document ).ready(
	function() {
	$(".personInput").tokenInput("/person");
});


$( document ).on( "click", ".personInput", function() {
  	$(".personInput").tokenInput("/person");
});
