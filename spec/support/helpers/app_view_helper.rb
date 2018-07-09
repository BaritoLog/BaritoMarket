module AppViewHelper
  def self.generate_list_cell_content(class_list=[], content)
    "<td class=\"#{class_list.join(' ')}\">#{content}</td>"
  end
end
