(function($){
  function handleJoinVisibility() {
    if($("#joins").prop("checked")) {
      $("tr.join").hide();
    } else {
      $("tr.join").show();
    }
  }

  $("#joins").on("click", handleJoinVisibility);
  handleJoinVisibility();
})(jQuery);
