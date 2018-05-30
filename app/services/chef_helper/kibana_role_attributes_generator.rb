module ChefHelper
  class KibanaRoleAttributesGenerator
    def initialize(opts = {})
      @role_name = opts[:role_name] || 'kibana'
    end

    def generate
      {
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
