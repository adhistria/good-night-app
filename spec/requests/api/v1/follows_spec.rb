require 'rails_helper'

RSpec.describe "Api::V1::Follows", type: :request do
  let(:user) { User.create!(name: "Follower") }
  let(:target_user) { User.create!(name: "Following") }
  let(:headers) { { 'X-User-ID' => user.id.to_s } }

  describe "POST /api/v1/follows" do
    context "with valid user to follow" do
      it "creates a follow relationship" do
        expect {
          post api_v1_follows_path, params: { following_id: target_user.id }, headers: headers
        }.to change(Follow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['message']).to include('Successfully followed')
      end
    end

    context "when already following" do
      before do
        user.following << target_user
      end

      it "returns error" do
        post api_v1_follows_path, params: { following_id: target_user.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('Already following')
      end
    end

    context "when trying to follow self" do
      it "returns error" do
        post api_v1_follows_path, params: { following_id: user.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('Cannot follow yourself')
      end
    end

    context "with non-existent user" do
      it "returns not found" do
        post api_v1_follows_path, params: { following_id: 999 }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('not found')
      end
    end
  end


  describe "DELETE /api/v1/follows/:following_id" do
    context "when following exists" do
      before do
        user.following << target_user
      end

      it "destroys the follow relationship" do
        expect {
          delete api_v1_unfollow_user_path(following_id: target_user.id), headers: headers
        }.to change(Follow, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to include('Successfully unfollowed')
      end
    end

    context "when not following" do
      it "returns not found" do
        delete api_v1_unfollow_user_path(following_id: target_user.id), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to include('Not following')
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
