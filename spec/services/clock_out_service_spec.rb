require 'rails_helper'

RSpec.describe ClockOutService do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user, clock_in: 1.hour.ago, clock_out: nil) }
  let(:service) { described_class.new(user, sleep_record.id) }

  describe '.call' do
    context 'when sleep record exists and is not clocked out' do
      it 'updates the clock_out time' do
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to include('Clock out successful')
        expect(sleep_record.reload.clock_out).to be_present
        expect(result[:data]).to eq(sleep_record)
      end

      it 'calculates sleep duration' do
        result = service.call

        expect(result[:success]).to be true
        expect(sleep_record.reload.sleep_duration).to be > 0
      end
    end

    context 'when sleep record does not exist' do
      let(:service) { described_class.new(user, 999) }

      it 'returns an error message' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to include('not found')
      end
    end

    context 'when sleep record already has clock_out time' do
      before do
        sleep_record.update(clock_out: 30.minutes.ago)
      end

      it 'returns an error message' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to include('Already clocked out')
      end
    end

    context 'when sleep record belongs to another user' do
      let(:other_user) { create(:user) }
      let(:other_sleep_record) { create(:sleep_record, user: other_user) }
      let(:service) { described_class.new(user, other_sleep_record.id) }

      it 'returns not found error' do
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to include('not found')
      end
    end

    context 'when update fails' do
      before do
        allow_any_instance_of(SleepRecord).to receive(:update).and_return(false)
      end

      it 'returns an error message' do
        result = service.call

        expect(result[:success]).to be false
      end
    end
  end
end