FactoryBot.define do
  factory :ext_app do
    sequence(:name) {|n| "ext_app_#{n}" }
    description "Description"
    access_token SecureRandom.urlsafe_base64(48)
    association :created_by, factory: :user
  end
end
