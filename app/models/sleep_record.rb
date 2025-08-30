class SleepRecord < ApplicationRecord
  belongs_to :user
  before_save :set_sleep_duration

  private

  def set_sleep_duration
    return unless clock_out.present? && clock_in.present?
    self.sleep_duration = clock_out - clock_in
  end
end
