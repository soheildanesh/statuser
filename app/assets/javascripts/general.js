
//for token input autocomplete///// 		
$( document ).ready(
	function() {
	$(".personInput").tokenInput("/person");
});
//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".personInput", function() {
  	$(".personInput").tokenInput("/person");
});


//http://loopj.com/jquery-tokeninput/
$( document ).ready(function() {
	
	// var dbid = $("#data").data('sitedbid'); this is the db id (ie _id fields in mongodb) not the siteId assigned by us, don't need it
	
	$(".siteidInput").tokenInput("/site", 
		{tokenLimit: 1}
	);
	
	
	//prepopulate with the site from which they clicked the 'submit activity report' link
	var siteId = $("#data").data('siteid');

	$(".siteidInput").tokenInput("add", {id: siteId, name: siteId } );	
	
});
$( document ).on( "focus", ".siteidInput", function() {
	$(".siteidInput").tokenInput("/site", 
		{tokenLimit: 1}
	);
});
//http://loopj.com/jquery-tokeninput/


$( document ).ready(
	function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
$( document ).on( "focus", ".siteTask", function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
///////////////////////////////////



