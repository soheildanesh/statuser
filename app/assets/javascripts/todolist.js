
$( document ).on( "keyup", ".task", function(e) {
	//alert("yoooo");
	var charCode = e.which;
	
	if(charCode == 13){
		$( "#todolistForm" ).submit();	
	}
		
});