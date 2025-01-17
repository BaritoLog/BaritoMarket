var app_groups = {
  init: function() {
    $("#assign_app_group_id").select2({
      placeholder: "Select app group",
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

    $("[id^='toggle_infra_status_']").change(function() {
      var appGroupId = $(this).data("id");
      var isChecked = $(this).prop("checked");
      var $form = $("#form_toggle_infra_status_" + appGroupId);
      $form.find("#toggle_status").val(isChecked);
      $form.submit();
    });

    $("[id^='toggle_redact_status_']").change(function() {
      var appGroupId = $(this).data("id");
      var isChecked = $(this).prop("checked");
      var $form = $("#form_toggle_redact_status_" + appGroupId);
      $form.find("#toggle_redact_status").val(isChecked);
      $form.submit();
    });
   
    $("[id^='toggle_elasticsearch_status_']").change(function() {
      var appGroupId = $(this).data("id");
      var isChecked = $(this).prop("checked");
      var $form = $("#form_toggle_elasticsearch_status_" + appGroupId);
      $form.find("#toggle_elasticsearch_status").val(isChecked);
      $form.submit();
    });
    
    $("[id^='toggle_app_group_status_']").change(function() {
      var appGroupId = $(this).data("id");
      var isChecked = $(this).prop("checked");
      var $form = $("#form_toggle_app_group_status_" + appGroupId);
      $form.find("#toggle_app_group_status").val(isChecked);
      $form.submit();
    });

    $("[id^='toggle_apps_list_']").hover(function() {
      var appGroupId = $(this).data("id");
      $("#toggle_apps_list_" + appGroupId).popover({
        placement: 'right',
        title: 'Apps',
        trigger: 'hover',
        html: true,
        content: function () {
          return $("#toggle_apps_content_" + appGroupId).html();
        }
      });
    });

    $("[id='maskedcharstart']").hover(function() {
      $("#maskedcharstart").popover({
        placement: 'right',
        trigger: 'hover',
        html: true,
        content: function () {
          return "Index from left where your masking would start";
        }
      });
    });

    $("[id='maskedcharend']").hover(function() {
      $("#maskedcharend").popover({
        placement: 'right',
        trigger: 'hover',
        html: true,
        content: function () {
          return "Index from right where your masking would end";
        }
      });
    });
  }
}

$(function() {
  app_groups.init();
});
