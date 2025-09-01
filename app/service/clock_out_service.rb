class ClockOutService
  def initialize(user, sleep_record_id)
    @user = user
    @sleep_record_id = sleep_record_id
  end

  def call
    sleep_record = @user.sleep_records.find_by(id: @sleep_record_id)

    return { success: false, errors: "Sleep record not found" } unless sleep_record
    return { success: false, errors: "Already clocked out" } if sleep_record.clock_out.present?

    if sleep_record.update(clock_out: Time.current)
      { success: true, message: "Clock out successful", data: sleep_record }
    else
      { success: false, errors: sleep_record.errors.full_messages.join(", ") }
    end
  end

end
