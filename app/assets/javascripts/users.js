var users = {
  init: function() {
    $("#assign_member_user_id").select2({
      placeholder: "Choose admin user",
      minimumInputLength: 3,
      ajax: {
        url: "/users/search",
        dataType: "json",
        data: function(params) {
          var query = {
            q: params.term
          }
          return query;
        },
        delay: 250,
        processResults: function(data) {
          return {
            results: $.map(data, function(user, i) {
              text = user.username;
              if (!text) text = user.email;
              return { id: user.id, text: text }
            })
          };
        }
      }
    });
  }
}

$(function() {
  users.init();
});
