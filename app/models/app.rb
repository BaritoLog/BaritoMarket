class App < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :app_group, required: true
  belongs_to :log_template, required: true
end
