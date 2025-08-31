class User < ApplicationRecord

  validates :name, presence: true
  has_many :followed_relationships, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :followed_relationships, source: :following
  has_many :follower_relationships, class_name: "Follow", foreign_key: "following_id", dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

end
