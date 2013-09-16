(function($){
  function handleJoinVisibility() {
    if($("#joins").prop("checked")) {
      $("tr.join").hide();
    } else {
      $("tr.join").show();
    }
  }

  function formatDates() {
    $("td.timestamp").each(function(i, ts) {
      var timestamp = moment.utc($(ts).text() + "+0000");
      $(ts).text(timestamp.tz("America/Chicago").format("YYYY/MM/DD hh:mm a zz"));
    });
  }

  $("#joins").on("click", handleJoinVisibility);
  formatDates();
  handleJoinVisibility();
})(jQuery);
