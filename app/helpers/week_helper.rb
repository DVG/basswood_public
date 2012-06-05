module WeekHelper
  def week_for_date(date)
    (date.to_date.beginning_of_week(:sunday)..date.to_date.end_of_week(:sunday))
  end
end