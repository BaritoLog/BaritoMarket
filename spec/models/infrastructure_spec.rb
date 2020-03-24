require 'rails_helper'

RSpec.describe Infrastructure, type: :model do
  describe 'Add Infrastructure Component' do
    let(:infrastructure) { create :infrastructure }
    let(:cluster_template) { create :cluster_template }
    before(:each) do
      @components = infrastructure.generate_components(cluster_template.manifests)
    end

    it 'should generate correct number of components' do
      @components.each_with_index do |node, seq|
        infrastructure.add_component(node, seq + 1)
      end
      
      expect(infrastructure.infrastructure_components.count).
        to eq(@components.count)
    end
  end

  context 'Setup Application' do
    let(:cluster_template) { create :cluster_template }
    let(:infrastructure_props) { build(:infrastructure) }

    before do
      allow(Infrastructure).to receive(:generate_cluster_index).
        and_return(1000)
      allow(Rufus::Mnemo).to receive(:from_i).with(1000).
        and_return(infrastructure_props.cluster_name)
      Sidekiq::Testing.fake!
    end

    it 'should create the infrastructure' do
      infrastructure = Infrastructure.setup(
        name: infrastructure_props.name,
        capacity: cluster_template.name,
        app_group_id: infrastructure_props.app_group_id,
        cluster_template_id: cluster_template.id,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      
      expect(infrastructure.persisted?).to eq(true)
      expect(infrastructure.provisioning_status).to eq(Infrastructure.provisioning_statuses[:pending])
      expect(infrastructure.status).to eq(Infrastructure.statuses[:inactive])
    end

    it 'shouldn\'t create infrastructure if app_group is invalid' do
      infrastructure = Infrastructure.setup(
        name: infrastructure_props.name,
        capacity: cluster_template.name,
        app_group_id: 'invalid_group',
        cluster_template_id: cluster_template.id,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      
      expect(infrastructure.persisted?).to eq(false)
      expect(infrastructure.valid?).to eq(false)
    end

    it 'should generate cluster name' do
      infrastructure = Infrastructure.setup(
        name: infrastructure_props.name,
        capacity: cluster_template.name,
        app_group_id: infrastructure_props.app_group_id,
        cluster_template_id: cluster_template.id,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      
      expect(infrastructure.cluster_name).to eq(
        Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      )
    end
  end

  context 'Status Update' do
    let(:infrastructure) { create(:infrastructure) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = infrastructure.update_status('sample')
      
      expect(status_update).to eq(false)
    end

    it 'should update infrastructure status' do
      status = Infrastructure.statuses.keys.sample
      status_update = infrastructure.update_status(status)
      
      expect(status_update).to eq(true)
      expect(infrastructure.status.downcase).to eq(status)
    end
  end

  context 'Provisioning Status Update' do
    let(:infrastructure) { create(:infrastructure) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = infrastructure.update_provisioning_status('sample')
      
      expect(status_update).to eq(false)
    end

    it 'should update provisioning status' do
      status = Infrastructure.provisioning_statuses.keys.sample
      status_update = infrastructure.update_provisioning_status(status)
      
      expect(status_update).to eq(true)
      expect(infrastructure.provisioning_status.downcase).to eq(status)
    end
  end

  context 'It should generate receiver url' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should generate proper receiver url for logs' do
      url = "#{Figaro.env.router_protocol}://"\
            "#{Figaro.env.router_domain}"\
            '/produce_batch'
      
      expect(infrastructure.receiver_url).to eq(url)
    end
  end

  context 'It should generate viewer url' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should generate proper viewer url for logs' do
      url = "#{Figaro.env.viewer_protocol}://"\
            "#{infrastructure.cluster_name}.#{Figaro.env.viewer_domain}"
      
      expect(infrastructure.viewer_url).to eq(url)
    end
  end

  context 'It should get the app group name' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should return the app group name' do
      expect(infrastructure.app_group_name).to eq(infrastructure.app_group.name)
    end
  end

  context 'It should get the next cluster index' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should get the the next cluster index' do
      expect(Infrastructure.generate_cluster_index).to eq(Infrastructure.all.size + 1000)
    end
  end

  describe '#provisioning_error?' do
    it 'should return true if provisioning is error' do
      infrastructure = build(:infrastructure, provisioning_status: 'PROVISIONING_ERROR')
      
      expect(infrastructure.provisioning_error?).to eq true
    end
  end

  describe '#allow_delete?' do
    let(:infrastructure_props) { build(:infrastructure) }
    let(:cluster_template) { create(:cluster_template) }

    it 'should return true if infrastructure can be deleted' do
      infrastructure = Infrastructure.setup(
        name: infrastructure_props.name,
        capacity: cluster_template.name,
        app_group_id: infrastructure_props.app_group_id,
        cluster_template_id: cluster_template.id,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      infrastructure.update_status('INACTIVE')
      infrastructure.update_provisioning_status('FINISHED')
      
      expect(infrastructure.allow_delete?).to eq true
    end

    it 'should return false if infrastructure cannot be deleted' do
      infrastructure = Infrastructure.setup(
        name: infrastructure_props.name,
        capacity: cluster_template.name,
        app_group_id: infrastructure_props.app_group_id,
        cluster_template_id: cluster_template.id,
        manifests: cluster_template.manifests,
        options: cluster_template.options,
      )
      infrastructure.update_status('ACTIVE')
      infrastructure.update_provisioning_status('FINISHED')
      
      expect(infrastructure.allow_delete?).to eq false
    end
  end

  describe '#get_consul_hosts' do
    before(:each) do
      pf_host = Figaro.env.pathfinder_host
      pf_token = Figaro.env.pathfinder_token
      pf_cluster = Figaro.env.pathfinder_cluster
      @pf_provisioner = PathfinderProvisioner.new(pf_host, pf_token, pf_cluster)
      @manifest = {
        "name" => "haza-consul",
        "cluster_name" => "barito",
        "deployment_cluster_name"=>"haza",
        "type" => "consul",
        "desired_num_replicas" => 1,
        "min_available_replicas" => 0,
        "definition" => {
          "container_type" => "stateless",
          "strategy" => "RollingUpdate",
          "allow_failure" => "false",
          "source" => {
            "mode" => "pull",              # can be local or pull. default is pull.
            "alias" => "lxd-ubuntu-minimal-consul-1.1.0-8",
            "remote" => {
              "name" => "barito-registry"
            },
            "fingerprint" => "",
            "source_type" => "image"                      
          },
          "resource" => {
            "cpu_limit" => "0-2",
            "mem_limit" => "500MB"
          },
          "bootstrappers" => [{
            "bootstrap_type" => "chef-solo",
            "bootstrap_attributes" => {
              "consul" => {
                "hosts" => []
              },
              "run_list" => []
            },
            "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
          }],
          "healthcheck" => {
            "type" => "tcp",
            "port" => 9500,
            "endpoint" => "",
            "payload" => "",
            "timeout" => ""
          }
        }
      }
      @resp = {
          'success'=> true,
          'data' =>{
            "containers"=>[{
              "id"=>1817,
              "hostname"=>"haza-consul-01",
              "ipaddress"=>"10.0.0.1",
              "source"=>{
                "id"=>23,
                "source_type"=>"image",
                "mode"=>"pull",
                "remote"=>{
                  "id"=>1,
                  "name"=>"barito-registry",
                  "server"=>"https://localhost:8443",
                  "protocol"=>"lxd",
                  "auth_type"=>"tls"
                },
                "fingerprint"=>"",
                "alias"=>"lxd-ubuntu-minimal-consul-1.1.0-8"
              },
              "bootstrappers"=>[{
                "bootstrap_type"=>"chef-solo",
                "bootstrap_attributes"=>{
                  "consul"=>{
                    "hosts"=>["172.168.0.1", "172.168.0.2"]
                  },
                  "run_list"=>[]
                },
                "bootstrap_cookbooks_url"=>
                  "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"}],
              "node_hostname"=>"i-barito-worker-node-02",
              "status"=>"BOOTSTRAPPED",
              "last_status_update_at"=>"2020-03-19T07:27:54.885Z"}
            ]
          }
        }
    end

    it 'should return nil if infrastructure doesn\'t have consul manifest' do
      infrastructure =  create(:infrastructure, cluster_name: 'haza', manifests: {}) 
      
      expect(infrastructure.fetch_consul_hosts).to eq []
    end

    it 'should return list of consul hosts if infrastructure have consul manifest' do
      infrastructure =  create(:infrastructure, cluster_name: 'haza', manifests: [@manifest]) 
      
      provisioner = double
      allow(provisioner).to(receive(:index_containers!).
        with('haza-consul', 'barito').and_return(@resp))
      allow(PathfinderProvisioner).to receive(:new).and_return(provisioner)

      expect(infrastructure.fetch_consul_hosts).to eq ["10.0.0.1:#{Figaro.env.default_consul_port}"]
    end
  end
end
