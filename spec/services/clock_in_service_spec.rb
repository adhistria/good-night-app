# spec/services/clock_in_service_spec.rb
require 'rails_helper'

RSpec.describe ClockInService do
  let(:user) { User.create(name: "user") }
  let(:service) { described_class.new(user) }

  describe '.call' do
    context 'when user has no active clock-in' do
      it 'creates a new sleep record with clock_in time' do
        result = service.call

        expect(result[:success]).to be true
        expect(user.sleep_records.count).to eq(1)
        expect(user.sleep_records.last.clock_in).to be_present
        expect(user.sleep_records.last.clock_out).to be_nil
      end

      it 'returns all sleep records in order' do
        create(:sleep_record, user: user, clock_in: 2.days.ago, clock_out: 1.day.ago)
        create(:sleep_record, user: user, clock_in: 3.days.ago, clock_out: 2.days.ago)

        result = service.call

        expect(result[:success]).to be true
        expect(result[:sleep_records].count).to eq(3)
      end
    end

    context 'when user has an active clock-in' do
      before do
        create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil)
      end

      it 'returns an error message' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:errors]).to include('Already clocked in, please clock out first')
        expect(user.sleep_records.count).to eq(1)
      end
    end
  end
end