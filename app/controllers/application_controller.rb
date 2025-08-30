class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    set_user
    return if @user

    render json: { error: "Not Authorized" }, status: :unauthorized
  end

  def set_user
    user_id = request.headers['X-User-ID']
    return if user_id.blank?

    @user = User.find_by(id: user_id)
  end

end
