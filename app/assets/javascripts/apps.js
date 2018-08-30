var apps = {
  init: function() {
    $("[id^='toggle_app_status_']").change(function() {
      var appId = $(this).data("id");
      var isChecked = $(this).prop("checked");
      var $form = $("#form_toggle_app_status_" + appId);
      $form.find("#toggle_status").val(isChecked);
      $form.submit();
    });

  }
};

$(function() {
  apps.init();
});
