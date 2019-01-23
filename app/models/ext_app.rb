class ExtApp < ApplicationRecord
  NAME_FORMAT = /\A(?![._\-\/ ])[\p{Alpha}\d._\-\/ ]+(?<![._\-\/ ])\z/

  attr_accessor :access_token

  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: NAME_FORMAT },
    length: { minimum: 4, maximum: 60 }
  validates :created_by_id, presence: true

  belongs_to :created_by, class_name: 'User'

  before_save :hash_access_token!

  def self.valid_access_token? challenge_token
    return false unless challenge_token.present?
    ExtApp.
      where(hashed_access_token: Digest::SHA512.hexdigest(challenge_token)).
      present?
  end

  private
    def hash_access_token!
      if self.access_token.present?
        self.hashed_access_token = Digest::SHA512.hexdigest self.access_token
        self.access_token_generated_at = DateTime.current
        self.access_token = nil
      end
    end
end
