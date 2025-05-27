require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @activity = activities(:one)
    sign_in @user
  end

  test "should create question when authenticated" do
    assert_difference('Question.count') do
      post activity_questions_path(@activity), params: { 
        question: { 
          conteúdo: "Qual é a capital da França?",
          tipo: "multiple_choice"
        }
      }
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should update question when authenticated" do
    question = questions(:one)
    patch activity_question_path(@activity, question), params: { 
      question: { 
        conteúdo: "Nova pergunta atualizada"
      }
    }
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should destroy question when authenticated" do
    question = questions(:one)
    assert_difference('Question.count', -1) do
      delete activity_question_path(@activity, question)
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.id}/, response.location
  end

  test "should not allow access without authentication" do
    sign_out @user
    post activity_questions_path(@activity), params: { 
      question: { 
        conteúdo: "Test question"
      }
    }
    assert_redirected_to new_user_session_path
  end
end
