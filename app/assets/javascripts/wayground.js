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

function initializePage() {
  // Make the nav element interactive so it can be compact
  $("nav").addClass("interactive");
  $("nav .more").click(function(event){
    $("nav").toggleClass("clicked");
    event.preventDefault();
  });
  // Create the loading indicator
  $('<div id="loading-indicator"><img src="/images/indicator.gif" alt=" " /> Loading…</div>').prependTo('body');
}

$(document).ready(initializePage); // for normal loading of pages
$(document).on('page:load', initializePage); // for turbolinks loading of pages

// Show & hide the loading indicator when using turbolinks to fetch a new page
$(document).on('page:fetch', function() {
  $('#loading-indicator').show();
});
$(document).on('page:change', function() {
  $('#loading-indicator').hide();
/*  initializePage();*/
});
