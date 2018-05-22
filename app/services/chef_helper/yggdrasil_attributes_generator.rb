module ChefHelper
  class YggdrasilAttributesGenerator
    def initialize(opts = {})
      @role_name = opts[:role_name] || 'yggdrasil'
    end

    def generate
      {
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
