module ChefHelper
  class GenericRoleAttributesGenerator
    def generate(generator)
      generator.generate
    end

    protected
      def fetch_hosts_address_by(components, filter_type, filter)
        components.
          select{ |c| c.send(filter_type.to_sym) == filter }.
          collect{ |c| c.ipaddress || c.hostname }
      end
  end
end
