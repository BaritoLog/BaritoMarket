require 'rails_helper'

RSpec.describe ExtApp, type: :model do
  describe "callbacks" do
    describe "hash_access_token! before_save" do
      it "should hash access token and put it into hashed_access_token" do
        ext_app = create(:ext_app, access_token: "abc")
        expect(ext_app.hashed_access_token).to eq(
          Digest::SHA512.hexdigest("abc"))
      end
    end
  end

  describe "methods" do
    describe "self.valid_access_token?" do
      it "should return true if it finds matching access token" do
        ext_app = create(:ext_app, access_token: "abc")
        expect(ExtApp.valid_access_token?("abc")).to eq true
      end
    end
  end
end
