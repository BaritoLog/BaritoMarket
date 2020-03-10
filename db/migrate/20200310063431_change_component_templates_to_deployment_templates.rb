class ChangeComponentTemplatesToDeploymentTemplates < ActiveRecord::Migration[5.2]
  def change
      rename_table :component_templates, :deployment_templates
  end
end
