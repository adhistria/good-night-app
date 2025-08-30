require 'rails_helper'

RSpec.describe "Api::V1::Users", type: :request do

  def json_response
    JSON.parse(response.body)
  end

  describe "POST /api/v1/users" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            name: "John Doe"
          }
        }
      end

      it "creates a new user" do
        expect {
          post api_v1_users_path, params: valid_params
        }.to change(User, :count).by(1)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            name: ""
          }
        }
      end

      it "doesn't create a new user" do
        expect {
          post api_v1_users_path, params: invalid_params
        }.to change(User, :count).by(0)
      end
    end
  end
end
