var app_groups = {
  init: function() {
    $("#assign_app_group_id").select2({
      placeholder: "Select application groups",
      minimumInputLength: 3,
      ajax: {
        url: "/app_groups/search",
        dataType: "json",
        data: function(params) {
          var query = {
            q: params.term
          }

          return query;
        },
        processResults: function(data) {
          return {
            results: $.map(data, function(app, i) {
              return { id: app.id, text: app.name }
            })
          };
        }
      }
    });
  }
}

$(function() {
  app_groups.init();
});
