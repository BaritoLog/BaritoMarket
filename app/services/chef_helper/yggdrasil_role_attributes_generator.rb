module ChefHelper
  class YggdrasilRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @role_name = opts[:role_name] || 'yggdrasil'
    end

    def generate
      {
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
