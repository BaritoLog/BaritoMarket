FactoryBot.define do
  factory :chef_configs do
    initialize_with { new({
                              "some-instance" =>
                                  {
                                      "run_list"=>"some-instance",
                                      "chef_repo"=>"some-url"
                                  }
                          })
    }
  end
end
