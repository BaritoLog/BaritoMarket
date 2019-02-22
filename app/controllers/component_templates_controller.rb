class ComponentTemplatesController < ApplicationController

  def index
    @component_templates = ComponentTemplate.all
  end

  def new
    @component_template = ComponentTemplate.new
  end
end
