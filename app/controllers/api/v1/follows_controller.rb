class Api::V1::FollowsController < ApplicationController

  def create
    result = FollowService.new(@user, params[:following_id]).follow

    if result[:success]
      render json: { message: result[:message] }, status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def destroy
    result = FollowService.new(@user, params[:following_id]).unfollow

    if result[:success]
      render json: { message: result[:message] }
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end
