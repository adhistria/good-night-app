class FetchSleepRecordService
  def initialize(user, page, per_page)
    @user = user
    @page = page || 1
    @per_page = per_page || 10
  end

  def call
    records = SleepRecord
                .joins(:user)
                .where(user_id: @user.following.ids)
                .where("clock_in >= ?", 1.week.ago.beginning_of_day)
                .order(sleep_duration: :desc)
                .page(@page)
                .per(@per_page)

    {
      data: records,
      meta: pagination_meta(records)
    }
  end

  private

  def pagination_meta(records)
    {
      current_page: records.current_page,
      next_page: records.next_page,
      prev_page: records.prev_page,
      total_pages: records.total_pages,
      total_count: records.total_count
    }
  end
end
