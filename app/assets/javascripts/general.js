
$( document ).on("keyup change", function() {
	
	var empty = false;
   	$.each( $('.required'), function(index, field) {
		console.log("index = "+index+" value = "+ field.value + " value.length = "+field.value.length );
        if (field.value.length == 0 ) {
            empty = true;
        }
    });

    if (empty || !validateProjectDates()) {
        $('.disabledTillFilled').attr('disabled', 'disabled'); // updated according to http://stackoverflow.com/questions/7637790/how-to-remove-disabled-attribute-with-jquery-ie
    } else if(validateProjectDates()) {
        $('.disabledTillFilled').removeAttr('disabled'); // updated according to http://stackoverflow.com/questions/7637790/how-to-remove-disabled-attribute-with-jquery-ie
    }
});

function validateProjectDates(){
	if($("#project_endDate_1i").val() > $("#project_startDate_1i").val()){
		return true;
	}
	else if($("#project_endDate_1i").val() >= $("#project_startDate_1i").val() && 	$("#project_endDate_2i").val() > $("#project_startDate_2i").val() ){
		return true;
	}
	else if($("#project_endDate_1i").val() >= $("#project_startDate_1i").val() && $("#project_endDate_2i").val() >= $("#project_startDate_2i").val() && 
$("#project_endDate_3i").val() > $("#project_startDate_3i").val() ){
		return true
	}
	else{
		return false;
	}
}

$(document).on("click", '.showCrs', function(){
	$(this).siblings('.listOfCrs').toggle();
	return false;
});


//for token input autocomplete///// 	
$( document ).ready(
	function() {
	$(".projectTypeInput").tokenInput("/project_type",
	{tokenLimit: 1});
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".customerInput", function() {
  	$(".projectTypeInput").tokenInput("/project_type",
	{tokenLimit: 1});
});



$( document ).ready(
	function() {
	$(".customerInput").tokenInput("/customer",
	{tokenLimit: 1});
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".customerInput", function() {
  	$(".customerInput").tokenInput("/customer",
	{tokenLimit: 1});
});



$( document ).ready(
	function() {
	$(".programInput").tokenInput("/program",
	{tokenLimit: 1});
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".programInput", function() {
  	$(".programInput").tokenInput("/program",
	{tokenLimit: 1});
});



	
$( document ).ready(
	function() {
	$(".personInput").tokenInput("/person",
	{tokenLimit: 1});
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".personInput", function() {
  	$(".personInput").tokenInput("/person",
	{tokenLimit: 1});
});


//http://loopj.com/jquery-tokeninput/
$( document ).ready(function() {
	
	// var dbid = $("#data").data('sitedbid'); this is the db id (ie _id fields in mongodb) not the siteId assigned by us, don't need it
	
	$(".siteidInput").tokenInput("/site", 
		{tokenLimit: 1}
	);
	
	
	//prepopulate with the site from which they clicked the 'submit activity report' link
	//var siteId = $("#data").data('siteid');
	//if(siteId != 'null'){
	//	$(".siteidInput").tokenInput("add", {id: siteId, name: siteId } );	
	//}

	
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



