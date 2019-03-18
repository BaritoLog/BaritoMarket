module ChefHelper
  class KibanaRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @elasticsearch_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'elasticsearch')
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'kibana'
      @base_path = component.infrastructure.cluster_name
      @ipaddress = component.ipaddress
      kibana_property = ComponentProperty.find_by(name: 'kibana')
      @kibana_attrs = kibana_property.component_attributes
      @elasticsearch_url = "http://#{@elasticsearch_hosts.first}:#{@elasticsearch_port}"
    end

    def generate
      return {} if @kibana_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @kibana_attrs['kibana']['version'] = '6.3.0'
      @kibana_attrs['kibana']['config']['elasticsearch.url'] = @elasticsearch_url
      @kibana_attrs['kibana']['config']['server.basePath'] = "/#{@base_path}"
      @kibana_attrs['consul']['hosts'] = @consul_hosts
      @kibana_attrs['consul']['run_as_server'] = false
      @kibana_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @kibana_attrs['run_list'] = ["role[#{@role_name}]"]

      @kibana_attrs
    end
  end
end