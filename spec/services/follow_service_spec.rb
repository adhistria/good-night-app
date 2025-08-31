require 'rails_helper'

RSpec.describe FollowService do
  let(:follower) {User.create(name: "follower")}
  let(:user_to_follow) { User.create(name: "user_to_follow") }
  let(:followed_id) { user_to_follow.id }

  describe 'initialize' do
    it 'sets follower and finds followed_user' do
      service = described_class.new(follower, followed_id)

      expect(service.follower).to eq(follower)
      expect(service.followed_user).to eq(user_to_follow)
    end

    it 'sets followed_user to nil when user not found' do
      service = described_class.new(follower, 999)

      expect(service.followed_user).to be_nil
    end
  end

  describe '.follow' do
    context 'when followed user exists' do
      let(:service) { described_class.new(follower, followed_id) }

      it 'successfully follows a user' do
        result = service.follow

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Successfully followed user')
        expect(follower.following).to include(user_to_follow)
      end

      it 'returns error when trying to follow yourself' do
        service = described_class.new(follower, follower.id)
        result = service.follow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Cannot follow yourself')
        expect(follower.following).not_to include(follower)
      end

      it 'returns error when already following the user' do
        follower.following << user_to_follow
        result = service.follow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Already following this user')
      end

      it 'handles ActiveRecord validation errors' do
        allow(Follow).to receive(:create).and_raise(ActiveRecord::RecordInvalid.new(follower))

        result = service.follow

        expect(result[:success]).to be false
        expect(result[:error]).to be_present
      end
    end

    context 'when followed user does not exist' do
      let(:service) { described_class.new(follower, 999) }

      it 'returns error' do
        result = service.follow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('User to follow not found')
        expect(follower.following).to be_empty
      end
    end
  end

  describe '.unfollow' do
    context 'when followed user exists' do
      let(:service) { described_class.new(follower, followed_id) }

      it 'successfully unfollows a user' do
        follower.following << user_to_follow

        result = service.unfollow

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Successfully unfollowed user')
        expect(follower.following).not_to include(user_to_follow)
      end

      it 'returns error when not following the user' do
        result = service.unfollow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Not following this user')
      end

      it 'returns error when unfollow fails' do
        follower.following << user_to_follow
        follow = follower.followed_relationships.last
        allow(follow).to receive(:destroy).and_return(false)
        allow(follower.followed_relationships).to receive(:find_by).and_return(follow)

        result = service.unfollow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('Failed to unfollow user')
      end
    end

    context 'when followed user does not exist' do
      let(:service) { described_class.new(follower, 999) }

      it 'returns error' do
        result = service.unfollow

        expect(result[:success]).to be false
        expect(result[:error]).to eq('User to unfollow not found')
      end
    end
  end

  context 'integration tests' do
    it 'can follow and then unfollow a user' do
      follow_service = described_class.new(follower, followed_id)
      follow_result = follow_service.follow

      expect(follow_result[:success]).to be true
      expect(follower.following.count).to eq(1)

      unfollow_service = described_class.new(follower, followed_id)
      unfollow_result = unfollow_service.unfollow

      expect(unfollow_result[:success]).to be true
      expect(follower.following.count).to eq(0)
    end

    it 'cannot follow the same user twice' do
      service = described_class.new(follower, followed_id)

      first_result = service.follow
      expect(first_result[:success]).to be true

      second_result = service.follow
      expect(second_result[:success]).to be false
      expect(second_result[:error]).to eq('Already following this user')
    end
  end
end