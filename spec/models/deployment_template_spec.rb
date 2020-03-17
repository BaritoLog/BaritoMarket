require 'rails_helper'

RSpec.describe DeploymentTemplate, type: :model do
  context 'Create master data' do
    let(:deployment_template_props) { build(:deployment_template) }

    it 'should create the deployment_template' do
      deployment_template = create(:deployment_template,
        name: deployment_template_props.name,
        bootstrappers: deployment_template_props.bootstrappers,
      )

      expect(deployment_template.persisted?).to eq(true)
    end
  end

  context 'Deployment template name should be unique' do
    let(:deployment_template_props) { build(:deployment_template) }
    before(:each) do
      @deployment_template = create(:deployment_template)
    end

    it 'should not create the deployment_template' do
      deployment_template = DeploymentTemplate.create(
        name: @deployment_template.name,
        bootstrappers: deployment_template_props.bootstrappers,
      )

      expect(deployment_template.persisted?).to eq(false)
    end
  end
end
