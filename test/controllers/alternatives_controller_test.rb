require "test_helper"

class AlternativesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @activity = activities(:one)
    @question = questions(:one)
    sign_in @user
  end

  test "should create alternative when authenticated" do
    assert_difference('Alternative.count') do
      post activity_question_alternatives_path(@activity, @question), params: { 
        alternative: { 
          conteúdo: "Esta é uma alternativa de teste",
          correta: false
        }
      }
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should update alternative when authenticated" do
    alternative = alternatives(:one)
    patch activity_question_alternative_path(@activity, @question, alternative), params: { 
      alternative: { 
        conteúdo: "Alternativa atualizada"
      }
    }
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should destroy alternative when authenticated" do
    alternative = alternatives(:one)
    assert_difference('Alternative.count', -1) do
      delete activity_question_alternative_path(@activity, @question, alternative)
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should not allow access without authentication" do
    sign_out @user
    post activity_question_alternatives_path(@activity, @question), params: { 
      alternative: { 
        conteúdo: "Test alternative"
      }
    }
    assert_redirected_to new_user_session_path
  end
end
