
$(document).on("change", function(){
	var selected = $("#actionSelect").val();
	$(".action").hide();
	if(selected == 'set due date'){
		$("#dueDateSelector").show();
	}
	else if(selected == 'set start date'){
		$("#startDateSelector").show();
	}
	else if(selected == 'mark done'){
		
	}
});



function calcTotal(orderLineNum){
	if(orderLineNum == undefined)
	{
		
	}
	else
	{
		if(false){
			unitPrice = $("#_order_po_lines_"+orderLineNum+"_unitPrice").val();
			quantity = $("#_order_po_lines_"+orderLineNum+"_quantity").val();
			total = unitPrice * quantity;
			$("#_order_po_lines_"+orderLineNum+"totalPrice").val(total);
			alert(total);
		}
	}

}


//verify project form is filled out correctly before enabling submit
$( document ).on("keyup change", function() {
	
	var empty = false;
   	$.each( $('.required'), function(index, field) {
		//console.log("index = "+index+" value = "+ field.value + " value.length = "+field.value.length );
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
		
		if('gon' in window && gon.bidItemTypes != undefined && gon.bidItemTypes != null)
		{
			for (var i = 0; i < gon.bidItemTypes.length; i++) {
				if(gon.bidItemTypes[i] != null)
				{
					$("#_order_bid_lines_"+String(i+1)+"_itemType").tokenInput("/item_type",
					{prePopulate: gon.bidItemTypes[i],
					tokenLimit: 1});
				}
				else
				{
					$("#_order_bid_lines_"+String(i+1)+"_itemType").tokenInput("/item_type",
					{tokenLimit: 1});
					
				}
				
			}
		}
		
		
		if('gon' in window && gon.poItemTypes != undefined && gon.poItemTypes != null)
		{
			for (var i = 0; i < gon.poItemTypes.length; i++) {
				
				if(gon.poItemTypes[i] != null)
				{
					$("#_order_po_lines_"+String(i+1)+"_itemType").tokenInput("/item_type",
					{prePopulate: gon.poItemTypes[i],
					tokenLimit: 1});
				}
				else
				{
					$("#_order_po_lines_"+String(i+1)+"_itemType").tokenInput("/item_type",
					{tokenLimit: 1});
				}
				
			}
		}	
	}
);

$( document ).ready(
	function() {
	//console.log($(".itemTypeInput").height());
	$(".itemTypeInput").tokenInput("/item_type",
	{tokenLimit: 1});
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".itemTypeInput", function() {
  	$(".itemTypeInput").tokenInput("/item_type",
	{tokenLimit: 1});
});



function projTypeInputTokenInput() {
	
	if('gon' in window && gon.projType != undefined && gon.projType != null)
	{				
	  	$(".projTypeInput").tokenInput("/project_type",
		{prePopulate: gon.projType,
		tokenLimit: 1});
	}
	else
	{
		$(".projTypeInput").tokenInput("/project_type",
		{tokenLimit: 1});
	}
}

http://stackoverflow.com/questions/18770517/rails-4-how-to-use-document-ready-with-turbo-links
//$(document).on('page:load', projTypeInputTokenInput);

$( document ).on( "focus", ".projTypeInput",
	projTypeInputTokenInput
	/*function() {
	
		if('gon' in window && gon.projType != undefined && gon.projType != null)
		{				
		  	$(".projTypeInput").tokenInput("/project_type",
			{prePopulate: gon.projType,
			tokenLimit: 1});
		}
		else
		{
			$(".projTypeInput").tokenInput("/project_type",
			{tokenLimit: 1});
		}
	}*/

);



$( document ).ready(
	projTypeInputTokenInput
	/*
	function() {
		
		if('gon' in window && gon.projType != undefined && gon.projType != null)
		{				
		  	$(".projTypeInput").tokenInput("/project_type",
			{prePopulate: gon.projType,
			tokenLimit: 1});
		}
		else
		{
			$(".projTypeInput").tokenInput("/project_type",
			{tokenLimit: 1});
		}
	}*/

);




function customerSiteidTokenInput() {
	
	//without 'gon' in window, uncaught reference error causing no even the else to be run and allowing free style text instead of tokeninput
  	if('gon' in window && gon.siteId != undefined && gon.siteId != null)
	{				
	  	$(".siteidInput").tokenInput("/site",
		{prePopulate: gon.siteId,
		tokenLimit: 1});
	}
	else
	{
		$(".siteidInput").tokenInput("/site",
		{tokenLimit: 1});
	}
}
$(document).on('page:load', customerSiteidTokenInput);
$( document ).ready(
	customerSiteidTokenInput
);
$( document ).on( "focus", ".siteidInput", customerSiteidTokenInput);






function customerInputTokenInput() {
	//without 'gon' in window, uncaught reference error causing no even the else to be run and allowing free style text instead of tokeninput
  	if('gon' in window && gon.customer != undefined && gon.customer != null)
	{				
	  	$(".customerInput").tokenInput("/customer",
		{prePopulate: gon.customer,
		tokenLimit: 1});
	}
	else
	{
		$(".customerInput").tokenInput("/customer",
		{tokenLimit: 1});
	}
}

$(document).on('page:load', customerInputTokenInput);
$( document ).ready(
	customerInputTokenInput
	/*
	function() {
				
	if('gon' in window && gon.customer != undefined && gon.customer != null)
	{				
	  	$(".customerInput").tokenInput("/customer",
		{prePopulate: gon.customer,
		tokenLimit: 1});
	}
	else
	{
		$(".customerInput").tokenInput("/customer",
		{tokenLimit: 1});
	}
}*/

);


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked

$( document ).on( "focus", ".customerInput", 
	customerInputTokenInput
	/*function() {
	//without 'gon' in window, uncaught reference error causing no even the else to be run and allowing free style text instead of tokeninput
  	if('gon' in window && gon.customer != undefined && gon.customer != null)
	{				
	  	$(".customerInput").tokenInput("/customer",
		{prePopulate: gon.customer,
		tokenLimit: 1});
	}
	else
	{
		$(".customerInput").tokenInput("/customer",
		{tokenLimit: 1});
	}
	}*/
	
);


function programInputTokenInput() {
		
	if('gon' in window && gon.program != undefined && gon.program != null)
	{				
	  	$(".programInput").tokenInput("/program",
		{prePopulate: gon.program,
		tokenLimit: 1});
	}
	else
	{
		$(".programInput").tokenInput("/program",
		{tokenLimit: 1});
	}	
}

$(document).on('page:load', programInputTokenInput);

$( document ).ready(
	programInputTokenInput
	/*function() {
		
		if('gon' in window && gon.program != undefined && gon.program != null)
		{				
		  	$(".programInput").tokenInput("/program",
			{prePopulate: gon.program,
			tokenLimit: 1});
		}
		else
		{
			$(".programInput").tokenInput("/program",
			{tokenLimit: 1});
		}	
	}*/
);


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".programInput", function() {
	programInputTokenInput
	/*if('gon' in window && gon.program != undefined && gon.program != null)
	{
		program = gon.program
		
	  	$(".programInput").tokenInput("/program",
		{tokenLimit: 1,
		prePopulate: gon.program});			
	}
	else
	{
		$(".programInput").tokenInput("/program",
		{tokenLimit: 1});
	}*/
});

function projManagerTokenInput() {
	if('gon' in window && gon.projManager != undefined && gon.projManager != null)
	{				
	  	$(".projManager").tokenInput("/person",
		{prePopulate: gon.projManager,
		tokenLimit: 1});
	}
	else
	{
		$(".projManager").tokenInput("/person",
		{tokenLimit: 1});
	}	
}

http://stackoverflow.com/questions/18770517/rails-4-how-to-use-document-ready-with-turbo-links
$(document).on('page:load', projManagerTokenInput);

$( document ).ready(
	projManagerTokenInput
	/*function() {
		
		if('gon' in window && gon.projManager != undefined && gon.projManager != null)
		{				
		  	$(".projManager").tokenInput("/person",
			{prePopulate: gon.projManager,
			tokenLimit: 1});
		}
		else
		{
			$(".projManager").tokenInput("/person",
			{tokenLimit: 1});
		}	
	}*/
);

function progManagerAdminTokenInput() {
		
	if('gon' in window && gon.projManagerAdmin != undefined && gon.projManagerAdmin != null)
	{				
	  	$(".projManagerAdmin").tokenInput("/person",
		{prePopulate: gon.projManagerAdmin,
		tokenLimit: 1});
	}
	else
	{
		$(".projManagerAdmin").tokenInput("/person",
		{tokenLimit: 1});
	}	
}
$(document).on('page:load', progManagerAdminTokenInput);


$( document ).ready(
	progManagerAdminTokenInput
/*	function() {
		
		if('gon' in window && gon.projManagerAdmin != undefined && gon.projManagerAdmin != null)
		{				
		  	$(".projManagerAdmin").tokenInput("/person",
			{prePopulate: gon.projManagerAdmin,
			tokenLimit: 1});
		}
		else
		{
			$(".projManagerAdmin").tokenInput("/person",
			{tokenLimit: 1});
		}	
	}*/
);


function projectControllerTokenInput() {
		
	if('gon' in window && gon.projManager != undefined && gon.projManager != null)
	{				
	  	$(".projController").tokenInput("/person",
		{prePopulate: gon.projController,
		tokenLimit: 1});
	}
	else
	{
		$(".projController").tokenInput("/person",
		{tokenLimit: 1});
	}	
}

$(document).on('page:load', projectControllerTokenInput);

$( document ).ready(
	projectControllerTokenInput
	/*
	function() {
		
		if('gon' in window && gon.projManager != undefined && gon.projManager != null)
		{				
		  	$(".projController").tokenInput("/person",
			{prePopulate: gon.projController,
			tokenLimit: 1});
		}
		else
		{
			$(".projController").tokenInput("/person",
			{tokenLimit: 1});
		}	
	}*/
);


$( document ).ready(
	function() {
	$(".crewInput").tokenInput("/person");
});


//note the click case below exists because when taken to page after clicking input boxes aren't processed by topkeninput, this ensures that these are at least when clicked
$( document ).on( "focus", ".personInput", function() {
  	$(".crewInput").tokenInput("/person");
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


/*
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
*/

$( document ).ready(
	function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
$( document ).on( "focus", ".siteTask", function() {
	$(".siteTask").tokenInput("/site/dummy/siteTasks");
});
///////////////////////////////////


