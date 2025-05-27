require "test_helper"

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @activity = activities(:one)
    sign_in @user
  end

  test "should create suggestion when authenticated" do
    assert_difference('Suggestion.count') do
      post activity_suggestions_path(@activity), params: { 
        suggestion: { 
          conteúdo: "Esta é uma sugestão de teste"
        }
      }
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should update suggestion when authenticated" do
    suggestion = suggestions(:one)
    patch activity_suggestion_path(@activity, suggestion), params: { 
      suggestion: { 
        conteúdo: "Sugestão atualizada"
      }
    }
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should destroy suggestion when authenticated" do
    suggestion = suggestions(:one)
    assert_difference('Suggestion.count', -1) do
      delete activity_suggestion_path(@activity, suggestion)
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should not allow access without authentication" do
    sign_out @user
    post activity_suggestions_path(@activity), params: { 
      suggestion: { 
        conteúdo: "Test suggestion"
      }
    }
    assert_redirected_to new_user_session_path
  end
end
