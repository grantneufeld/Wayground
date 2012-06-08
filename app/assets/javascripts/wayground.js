function countChars(char_limit,field_id,count_display_id) {
  var char_field = document.getElementById(field_id);
  var count_field = document.getElementById(count_display_id)
  var content = char_field.value;
  var len = content.length;
  count_field.innerHTML = char_limit - len;
  if(len > char_limit) {
    count_field.className = 'charcounter_over'
  } else if(len > (char_limit - 10)) {
    count_field.className = 'charcounter_warn'
  } else {
    count_field.className = 'charcounter'
  }
}

// Make the nav element interactive so it can be compact
$(document).ready(function(){
	$("nav").addClass("interactive");
	$("nav .more").click(function(event){
		$("nav").toggleClass("clicked");
		event.preventDefault();
	});
});

