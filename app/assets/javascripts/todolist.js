
$( document ).on( "keyup", ".task", function(e) {
	//alert("yoooo");
	var charCode = e.which;
	
	if(charCode == 13){
		$( "#todolistForm" ).submit();	
	}
		
});


$( document ).ready(

	function(e) {
		//alert("yooooo");
		tasks = $(".task");//.eq(0).focus()
		tasks[tasks.length - 1].focus()
		console.log("tasks = " +  eval(tasks))
	}
);





//var last_element = my_array[my_array.length - 1];