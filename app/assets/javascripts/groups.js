var groups = {
  init: function() {
    $("#assign_group_id").select2({
      placeholder: "Select groups",
      minimumInputLength: 3,
      ajax: {
        url: "/groups/search",
        dataType: "json",
        data: function(params) {
          var query = {
            q: params.term
          }

          return query;
        },
        processResults: function(data) {
          return {
            results: $.map(data, function(group, i) {
              return { id: group.id, text: group.name }
            })
          };
        }
      }
    });
  }
}

$(function() {
  groups.init();
});
