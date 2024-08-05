require 'rails_helper'

RSpec.describe AppGroup, type: :model do
  let(:default_infrastructure_location) {
    create(:infrastructure_location, name: Figaro.env.default_infrastructure_location,
      kibana_address_format: '%s-kibana', producer_address_format: '%s-producer')
  }

  context 'uniqueness validation' do
    describe ':name' do
      subject { create(:app_group) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end
  end

  context 'presence validation' do
    it 'should check presence of name' do
      expect(build(:app_group, name: nil)).not_to be_valid
    end

    it 'should check presence of secret_key' do
      expect(build(:app_group, secret_key: nil)).not_to be_valid
    end
  end

  describe 'producer address' do
    let (:app_group) { create(:app_group) }
    let (:dc_location) { create(:infrastructure_location, name: 'dc', producer_address_format: '%s-dc') }

    context 'when producer_helm_infrastructure is nil' do
      context 'and has 1 helm_infrastructure' do
        let! (:helm_infrastructure) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
        it 'should return producer address from that helm_infrastructure' do
          expect(app_group.producer_address).to eq(helm_infrastructure.producer_address)
        end
      end

      context 'and has multiple helm_infrastructure' do
        let! (:dc_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
        let! (:default_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: default_infrastructure_location) }
        it 'should return producer address from that helm_infrastructure on default_location env' do
          expect(app_group.producer_address).to eq(default_helm_infra.producer_address)
        end

        context 'if if didn\'t have helm_infrastructure in default_location' do
          let! (:app_group2) { create(:app_group) }
          let! (:dc2_location) { create(:infrastructure_location, name: 'dc2', producer_address_format: '%s-dc2') }
          let! (:dc2_helm_infra1) { create(:helm_infrastructure, :active, app_group: app_group2, infrastructure_location: dc2_location) }
          let! (:dc2_helm_infra2) { create(:helm_infrastructure, :active, app_group: app_group2, infrastructure_location: dc_location) }
          it 'should return producer address from first helm_infrastructure' do
            expect(app_group2.producer_address).to eq(dc2_helm_infra1.producer_address)
          end
        end
      end
    end

    context 'when producer_helm_infrastructure is not nil' do
      let! (:dc_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
      let! (:default_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: default_infrastructure_location) }
      it 'should return producer address from that helm_infrastructure even if it has infra in default_location' do
        app_group.update(producer_helm_infrastructure_id: dc_helm_infra.id)
        expect(app_group.producer_address).to eq(dc_helm_infra.producer_address)
      end
    end
  end

  describe 'kibana address' do
    let (:app_group) { create(:app_group) }
    let (:dc_location) { create(:infrastructure_location, name: 'dc', kibana_address_format: '%s-dc') }

    context 'when kibana_helm_infrastructure is nil' do
      context 'and has 1 helm_infrastructure' do
        let! (:helm_infrastructure) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
        it 'should return kibana address from that helm_infrastructure' do
          expect(app_group.kibana_address).to eq(helm_infrastructure.kibana_address)
        end
      end

      context 'and has multiple helm_infrastructure' do
        let! (:dc_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
        let! (:default_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: default_infrastructure_location) }
        it 'should return kibana address from that helm_infrastructure on default_location env' do
          expect(app_group.kibana_address).to eq(default_helm_infra.kibana_address)
        end

        context 'if if didn\'t have helm_infrastructure in default_location' do
          let! (:app_group2) { create(:app_group) }
          let! (:dc2_location) { create(:infrastructure_location, name: 'dc2', kibana_address_format: '%s-dc2') }
          let! (:dc2_helm_infra1) { create(:helm_infrastructure, :active, app_group: app_group2, infrastructure_location: dc2_location) }
          let! (:dc2_helm_infra2) { create(:helm_infrastructure, :active, app_group: app_group2, infrastructure_location: dc_location) }
          it 'should return kibana address from first helm_infrastructure' do
            expect(app_group2.kibana_address).to eq(dc2_helm_infra1.kibana_address)
          end
        end
      end
    end

    context 'when kibana_helm_infrastructure is not nil' do
      let! (:dc_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: dc_location) }
      let! (:default_helm_infra) { create(:helm_infrastructure, :active, app_group: app_group, infrastructure_location: default_infrastructure_location) }
      it 'should return kibana address from that helm_infrastructure even if it has infra in default_location' do
        app_group.update(kibana_helm_infrastructure_id: dc_helm_infra.id)
        expect(app_group.kibana_address).to eq(dc_helm_infra.kibana_address)
      end
    end
  end

  context 'Setup Application' do
    let(:app_group_props) { build(:app_group) }
    let(:helm_cluster_template) { create(:helm_cluster_template) }

    it 'should create the app_group and helm_infra' do
      app_group, helm_infrastructure = AppGroup.setup(
        name: app_group_props.name,
        secret_key: AppGroup.generate_key,
        capacity: 'small',
        cluster_template_id: helm_cluster_template.id,
      )

      expect(app_group.persisted?).to eq(true)
      expect(helm_infrastructure.persisted?).to eq(true)
    end

    it 'should able to change environment to staging' do
      app_group, = AppGroup.setup(
        name: app_group_props.name,
        capacity: 'small',
        cluster_template_id: helm_cluster_template.id,
        environment: 'staging',
      )

      expect(app_group.staging?).to be true
    end
  end
end
