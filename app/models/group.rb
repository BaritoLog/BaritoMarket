class Group < ActiveRecord::Base
  GID_CONSTANT = 10000

  validates :name, presence: true

  after_save :set_gid

  def set_gid
    update_columns(gid: GID_CONSTANT + self.id)
  end
end
