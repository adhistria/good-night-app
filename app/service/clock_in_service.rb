class ClockInService
  def initialize(user)
    @user = user
  end

  def call
    if @user.sleep_records.where(clock_out: nil).exists?
      return { success: false, errors: "Already clocked in, please clock out first"}
    end

    sleep_record = SleepRecord.new(user: @user, clock_in: Time.current)
    if sleep_record.save
      {
        success: true,
        sleep_records: @user.sleep_records.order(created_at: :asc).map do |record|
          {
            id: record.id,
            clock_in: record.clock_in,
            clock_out: record.clock_out
          }
        end
      }
    else
      {
        success: false,
        errors: sleep_record.errors.full_messages.join(", ")
      }
    end
  end
end
