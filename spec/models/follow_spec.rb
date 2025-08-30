require 'rails_helper'

RSpec.describe Follow, type: :model do
  describe "associations" do
    it { should belong_to(:follower).class_name("User") }
    it { should belong_to(:following).class_name("User") }
  end

  describe "validations" do
    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:following_id) }
    it { should validate_uniqueness_of(:follower_id).scoped_to(:following_id) }
  end

  describe "follow relationship" do
    let(:user1) { User.create!(name: "User One") }
    let(:user2) { User.create!(name: "User Two") }

    it "is valid when a user follows another user" do
      follow = Follow.new(follower: user1, following: user2)
      expect(follow).to be_valid
    end

    it "is invalid when follower and following are the same user" do
      follow = Follow.new(follower: user1, following: user1)
      expect(follow).not_to be_valid
    end

    it "does not allow duplicate follows" do
      Follow.create!(follower: user1, following: user2)
      duplicate = Follow.new(follower: user1, following: user2)
      expect(duplicate).not_to be_valid
    end
  end

end
