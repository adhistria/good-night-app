class FollowService
  attr_reader :follower, :followed_user

  def initialize(follower, followed_id)
    @follower = follower
    @followed_user = User.find_by(id: followed_id)
  end

  def follow
    return { success: false, error: "User to follow not found" } unless followed_user
    return { success: false, error: "Cannot follow yourself" } if follower.id == followed_user.id
    return { success: false, error: "Already following this user" } if follower.following.include?(followed_user)

    begin
      Follow.create(follower: follower, following: followed_user)
      { success: true, message: "Successfully followed user"}
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.message }
    end
  end

  def unfollow
    return { success: false, error: "User to unfollow not found" } unless followed_user

    follow = follower.followed_relationships.find_by(following_id: followed_user.id)
    return { success: false, error: "Not following this user" } unless follow

    if follow.destroy
      { success: true, message: "Successfully unfollowed user" }
    else
      { success: false, error: "Failed to unfollow user" }
    end
  end

end