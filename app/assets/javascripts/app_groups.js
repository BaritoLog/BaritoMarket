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

    $(".application-sortable").on("click keydown", function(event) {
      if (event.type === "keydown" && event.key !== "Enter" && event.key !== " ") {
        return;
      }

      event.preventDefault();

      var $header = $(this);
      var $table = $header.closest("table");
      var $tbody = $table.find("tbody");
      var column = $header.data("sort-column");
      var type = $header.data("sort-type");
      var direction = $header.attr("aria-sort") === "ascending" ? "descending" : "ascending";
      var multiplier = direction === "ascending" ? 1 : -1;
      var rows = $tbody.find(".application-row").get();
      var $createRow = $tbody.find(".application-create-row").first();

      rows.sort(function(rowA, rowB) {
        var valueA = $(rowA).attr("data-sort-" + column);
        var valueB = $(rowB).attr("data-sort-" + column);

        if (type === "number") {
          valueA = Number(valueA);
          valueB = Number(valueB);
        }

        if (valueA < valueB) {
          return -1 * multiplier;
        }
        if (valueA > valueB) {
          return multiplier;
        }
        return 0;
      });

      $.each(rows, function(_, row) {
        if ($createRow.length) {
          $(row).insertBefore($createRow);
        } else {
          $tbody.append(row);
        }
      });

      $table.find(".application-sortable").attr("aria-sort", "none").
        find("i").removeClass("fa-sort-up fa-sort-down").addClass("fa-sort");
      $header.attr("aria-sort", direction).
        find("i").removeClass("fa-sort").addClass(direction === "ascending" ? "fa-sort-up" : "fa-sort-down");
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
