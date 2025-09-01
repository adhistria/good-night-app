require 'rails_helper'

RSpec.describe FetchSleepRecordService do
  let(:user) { create(:user) }
  let(:following_user1) { create(:user) }
  let(:following_user2) { create(:user) }
  let(:non_following_user) { create(:user) }

  before do
    user.following << following_user1
    user.following << following_user2
  end

  describe '.call' do
    context 'with sleep records from followed users' do
      before do
        create(:sleep_record, user: following_user1, clock_in: 3.days.ago, clock_out: 2.days.ago, sleep_duration: 28800) # 8 hours
        create(:sleep_record, user: following_user2, clock_in: 2.days.ago, clock_out: 1.day.ago, sleep_duration: 32400) # 9 hours
        create(:sleep_record, user: following_user1, clock_in: 1.day.ago, clock_out: Time.current, sleep_duration: 25200) # 7 hours

        create(:sleep_record, user: non_following_user, clock_in: 3.days.ago, clock_out: 2.days.ago) # Not followed
        create(:sleep_record, user: following_user1, clock_in: 2.weeks.ago, clock_out: 13.days.ago) # Too old
      end

      it 'returns sleep records from followed users in the past week' do
        service = described_class.new(user, 1, 10)
        result = service.call

        expect(result[:data].count).to eq(3)
        expect(result[:data].pluck(:user_id)).to all(be_in(user.following.ids))
      end

      it 'includes pagination metadata' do
        service = described_class.new(user, 1, 2)
        result = service.call

        expect(result[:meta]).to include(
                                   :current_page,
                                   :next_page,
                                   :prev_page,
                                   :total_pages,
                                   :total_count
                                 )
        expect(result[:meta][:current_page]).to eq(1)
      end

      it 'orders records by sleep duration descending' do
        service = described_class.new(user, 1, 10)
        result = service.call

        durations = result[:data].map(&:sleep_duration)
        expect(durations).to eq(durations.sort.reverse) # Should be descending order
      end
    end

    context 'with no sleep records' do
      it 'returns empty array with pagination meta' do
        service = described_class.new(user, 1, 10)
        result = service.call

        expect(result[:data]).to be_empty
        expect(result[:meta][:total_count]).to eq(0)
      end
    end

    context 'with pagination parameters' do
      before do
        15.times do |i|
          create(:sleep_record,
                 user: following_user1,
                 clock_in: (i+1).days.ago,
                 clock_out: i.days.ago,
                 sleep_duration: 21600 + (i * 3600))
        end
      end

      it 'uses default pagination values when nil' do
        service = described_class.new(user, nil, nil)
        result = service.call

        expect(result[:data].count).to be <= 10
        expect(result[:meta][:current_page]).to eq(1)
      end
    end

    context 'with clock_in boundary conditions' do
      it 'includes records from exactly 1 week ago' do
        record = create(:sleep_record,
                        user: following_user1,
                        clock_in: 1.week.ago.beginning_of_day,
                        clock_out: 1.week.ago.beginning_of_day + 8.hours)

        service = described_class.new(user, 1, 10)
        result = service.call

        expect(result[:data]).to include(record)
      end

      it 'excludes records from more than 1 week ago' do
        record = create(:sleep_record,
                        user: following_user1,
                        clock_in: 1.week.ago.beginning_of_day - 1.second,
                        clock_out: 1.week.ago.beginning_of_day + 8.hours)

        service = described_class.new(user, 1, 10)
        result = service.call

        expect(result[:data]).not_to include(record)
      end
    end
  end
end