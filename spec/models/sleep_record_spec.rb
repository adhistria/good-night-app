require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user) { User.create!(name: "adhi") }

  describe "callbacks" do
    context "when both clock_in and clock_out are present" do
      it "sets sleep_duration as the difference between clock_out and clock_in" do
        clock_in  = Time.current
        clock_out = clock_in + 8.hours

        record = SleepRecord.create!(
          user: user,
          clock_in: clock_in,
          clock_out: clock_out
        )

        expect(record.sleep_duration).to eq(8.hours)
      end
    end

    context "when clock_out is missing" do
      it "does not set sleep_duration" do
        clock_in = Time.current

        record = SleepRecord.create!(
          user: user,
          clock_in: clock_in,
          clock_out: nil
        )

        expect(record.sleep_duration).to be_nil
      end
    end

    context "when clock_in is missing" do
      it "raises not null violation" do
        expect {
          SleepRecord.create!(user: user, clock_in: nil, clock_out: Time.current)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

  end
end
