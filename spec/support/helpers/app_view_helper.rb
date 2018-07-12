module AppViewHelper
  def self.generate_list_cell_content(class_list=[], content)
    "<td class=\"#{class_list.join(' ')}\">#{content}</td>"
  end

  def set_select2_option(selector:, text:, value:)
    page.execute_script <<~JS
      var newOption = new Option("#{text}", "#{value}", false, false);
      $("#{selector}").append(newOption).trigger("change");
      $("#{selector}").val("#{value}").trigger("change");
    JS
  end
end
