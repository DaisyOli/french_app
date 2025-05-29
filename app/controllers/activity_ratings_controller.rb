class ActivityRatingsController < ApplicationController
  before_action :authenticate_student!
  before_action :set_activity, only: [:create, :update]
  before_action :set_rating, only: [:update]

  def create
    @rating = current_student.activity_ratings.build(rating_params)
    @rating.activity = @activity

    if @rating.save
      render json: { 
        status: 'success', 
        message: 'Merci pour votre évaluation !',
        rating: {
          stars: @rating.stars,
          comment: @rating.comment,
          average: @activity.average_rating,
          count: @activity.ratings_count
        }
      }
    else
      render json: { 
        status: 'error', 
        message: @rating.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  def update
    if @rating.update(rating_params)
      render json: { 
        status: 'success', 
        message: 'Évaluation mise à jour !',
        rating: {
          stars: @rating.stars,
          comment: @rating.comment,
          average: @activity.average_rating,
          count: @activity.ratings_count
        }
      }
    else
      render json: { 
        status: 'error', 
        message: @rating.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  def update_by_student
    @activity = Activity.find(params[:activity_id])
    @rating = current_student.activity_ratings.find_by!(activity: @activity)
    
    if @rating.update(rating_params)
      render json: { 
        status: 'success', 
        message: 'Évaluation mise à jour !',
        rating: {
          stars: @rating.stars,
          comment: @rating.comment,
          average: @activity.average_rating,
          count: @activity.ratings_count
        }
      }
    else
      render json: { 
        status: 'error', 
        message: @rating.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  def set_rating
    @rating = current_student.activity_ratings.find_by!(activity: @activity)
  end

  def rating_params
    params.require(:activity_rating).permit(:stars, :comment)
  end
end 