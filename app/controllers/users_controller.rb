class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_activities = current_user.activities
    @total_activities = @my_activities.count
    @total_attempts = CompletedActivity.where(activity: @my_activities).count
    @unique_students = CompletedActivity.where(activity: @my_activities).distinct.count(:student_id)
    avg = ActivityRating.where(activity: @my_activities).average(:stars)
    @average_rating = avg ? avg.round(1) : 0
    @recent_students = current_user.students.order(created_at: :desc).limit(3)
    @recent_ratings = ActivityRating.where(activity: @my_activities)
                                     .includes(:student, :activity)
                                     .recent.limit(4)
    @level_progress = ApplicationHelper::CEFR_COLORS.keys.map do |level|
      { level: level, total: @my_activities.where(nível: level).count }
    end
  end
end 