# Default dummy seeds

::FactoryBot.create(:group, name: "barito-superadmin")
::FactoryBot.create(:group, name: Figaro.env.global_viewer_role)