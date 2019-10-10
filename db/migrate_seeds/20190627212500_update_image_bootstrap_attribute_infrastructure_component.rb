class UpdateImageBootstrapAttributeInfrastructureComponent < ActiveRecord::Migration[5.2]
  def up
    ics = InfrastructureComponent.all
    source = {
      source_type: "image",       # can be image, migration or copy
      mode: "pull",              # can be local or pull. default is pull.
      remote: {
        name: "barito-registry"
      },
      fingerprint: "",
      alias: ""
    }

    bootstrappers = [{    
      bootstrap_type: "chef-solo",
      bootstrap_cookbooks_url: "",
      bootstrap_attributes: {}
    }]

    ics.each do |ic|
      case ic.component_type
      when "consul"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/consul-cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-consul-1.1.0-3"
      when "zookeeper"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/zookeeper-cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-zookeeper-3.4.12-1"
      when "kafka"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/kafka-cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-kafka-2.11-1"
      when "elasticsearch"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/elasticsearchwrapper_cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-elasticsearch-6.4.1-1"
      when "barito-flow-producer"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-barito-flow-producer-0.8.0-1"
      when "barito-flow-consumer"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/barito-flow-cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-barito-flow-consumer-0.8.0-1"
      when "kibana"
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://github.com/BaritoLog/kibana_wrapper_cookbook/archive/master.tar.gz"
        source[:alias] = "lxd-kibana-6.3.0-1"
      else
        bootstrappers[0][:bootstrap_cookbooks_url] = "https://cloud-images.ubuntu.com/releases"
        source[:alias] = "18.04"
      end

      bootstrappers[0][:bootstrap_attributes] = ic.bootstrappers
      ic.update(source: source, bootstrappers: bootstrappers)
    end
  end

  def down
    ics = InfrastructureComponent.all
    ics.each do |ic|
      ic.update(
        source: {},
        bootstrappers: [],
      )
    end
  end
end