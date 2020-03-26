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

      def generate_pf_meta(function_name, opts = {})
        uri = URI(function_name)
        uri.query = URI.encode_www_form(opts)
        
        "$pf-meta:#{uri.to_s}"
      end

      def bind_hosts_and_port(hosts, port, protocol=nil)
        if port
          hosts = hosts.map{ |host| "#{host}:#{port}" }
        end
        if protocol
          hosts = hosts.map{ |host| "#{protocol}://#{host}" }
        end

        hosts.join(',')
      end

      def get_bootstrap_attributes(bootstrappers)
        bootstrappers.each do |bootstrapper|
          case bootstrapper["bootstrap_type"]
          when "chef-solo"
            return bootstrapper["bootstrap_attributes"]
          else 
            return nil
          end
        end
      end
  end
end
