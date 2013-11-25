$(document).ready(function() {
  var lightBox = "empty";
  $("a.dialogLink").live('click',function(ev) {
    var link = $(ev.target)
    if ( lightBox == "empty") {
      lightBox = $('<div class="lightBox"/>').dialog({ autoOpen: false });  
    }
    $.get(link.attr('href')).complete(function(xhr) {
      var title = link.attr('title') || link.text();
      lightBox.dialog('option','title',title);
      lightBox.dialog('option','width','75%').dialog('option','height','650');
      $(lightBox).html(xhr.responseText)
      $("body").css("cursor", "auto");
      lightBox.dialog('open');
    });
    $("body").css("cursor", "progress");
    return false; // do not execute default href visit
  });
  $("button.dialogLink").live('click',function(ev) {
    var link = $(ev.target)
    if ( lightBox == "empty") {
      lightBox = $('<div class="lightBox"/>').dialog({ autoOpen: false });  
    }
    $.get(link.attr('href')).complete(function(xhr) {
      var title = link.attr('title') || link.text();
      lightBox.dialog('option','title',title);
      lightBox.dialog('option','width','75%').dialog('option','height','650');
      $(lightBox).html(xhr.responseText)
      $("body").css("cursor", "auto");
			
	$("#lightBox").position({
	   my: "center",
	   at: "center",
	   of: window
	});
      lightBox.dialog('open');
    });
    $("body").css("cursor", "progress");
    return false; // do not execute default href visit
  });
  $("a.smallDialogLink").live('click',function(ev) {
    var link = $(ev.target)
    if ( lightBox == "empty") {
      lightBox = $('<div class="lightBox"/>').dialog({ autoOpen: false });  
    }
    $.get(link.attr('href')).complete(function(xhr) {
      var title = link.attr('title') || link.text();
      lightBox.dialog('option','title',title);
      lightBox.dialog('option','position',['100px','100px']).dialog('option','width',600).dialog('option','height',300);
      $(lightBox).html(xhr.responseText)
      $("body").css("cursor", "auto");
      lightBox.dialog('open');
    });
    $("body").css("cursor", "progress");
    return false; // do not execute default href visit
  });
  $("form.dialogLink").live('submit',function(ev) {
    var form = ev.currentTarget;
    $('button',lightBox).attr('disabled','disabled')
    $.ajax({
      url: form.action,
      type: form.method,
      data: $(form).serialize()
    }).success(function(data) {
      $(lightBox).html(data)
    });

    return false;
  });
})
