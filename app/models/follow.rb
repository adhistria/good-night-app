class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User", foreign_key: "follower_id"
  belongs_to :following, class_name: "User", foreign_key: "following_id"

  validates :follower_id, presence: true
  validates :following_id, presence: true
  validates :follower_id, uniqueness: { scope: :following_id }

  validate :follower_and_following_cannot_be_same

  private

  def follower_and_following_cannot_be_same
    if follower_id == following_id
      errors.add(:following_id, "can't be the same as follower_id")
    end
  end

end
