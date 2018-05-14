FactoryBot.define do
  factory :tps_config do
    initialize_with { new({
                              "small" =>
                                  {
                                      "name"=>"Small",
                                      "tps_limit"=>100,
                                      "some_instances"=>2,
                                  }
                          })
    }
  end
end
