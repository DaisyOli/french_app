require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:one)
    @activity = activities(:one)
  end

  test "should redirect to login when not authenticated" do
    get activities_path
    assert_redirected_to new_user_session_path
  end

  test "should get index when authenticated as user" do
    sign_in @user
    get activities_path
    assert_response :success
    assert_select "h1", /Mes petites créations/i
  end

  test "should show activity" do
    sign_in @user
    get activity_path(@activity)
    assert_response :success
  end

  test "should get new when authenticated as user" do
    sign_in @user
    get new_activity_path
    assert_response :success
  end

  test "should create activity when authenticated as user" do
    sign_in @user
    
    assert_difference('Activity.count') do
      post activities_path, params: { 
        activity: { 
          título: "New Test Activity", 
          nível: "Débutant",
          texto: "Test content"
        } 
      }
    end
    
    assert_redirected_to activity_path(Activity.last)
  end

  test "should not create activity with invalid params" do
    sign_in @user
    
    assert_no_difference('Activity.count') do
      post activities_path, params: { 
        activity: { 
          título: "", # Invalid: empty title
          nível: "Débutant"
        } 
      }
    end
    
    assert_response :success # Should render new template with errors
  end

  test "should get edit when authenticated as user" do
    sign_in @user
    get edit_activity_path(@activity)
    assert_response :success
  end

  test "should update activity when authenticated as user" do
    sign_in @user
    
    patch activity_path(@activity), params: { 
      activity: { 
        título: "Updated Title",
        nível: "Intermédiaire"
      } 
    }
    
    assert_redirected_to activity_path(@activity)
    @activity.reload
    assert_equal "Updated Title", @activity.título
    assert_equal "Intermédiaire", @activity.nível
  end

  test "should destroy activity when authenticated as user" do
    sign_in @user
    
    assert_difference('Activity.count', -1) do
      delete activity_path(@activity)
    end
    
    assert_redirected_to activities_path
  end

  test "should get solve page without authentication" do
    get solve_activity_path(@activity)
    assert_response :success
  end

  test "should not allow student to access new activity" do
    student = Student.create!(email: "test@student.com", password: "password123")
    sign_in student
    
    get new_activity_path
    assert_redirected_to new_user_session_path
  end
end
