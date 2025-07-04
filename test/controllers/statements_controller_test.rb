require "test_helper"

class StatementsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @activity = activities(:one)
    sign_in @user
  end

  test "should create statement when authenticated" do
    assert_difference('Statement.count') do
      post activity_statements_path(@activity), params: { 
        statement: { 
          conteúdo: "Esta é uma declaração de teste"
        }
      }
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.slug}/, response.location
  end

  test "should update statement when authenticated" do
    statement = statements(:one)
    patch activity_statement_path(@activity, statement), params: { 
      statement: { 
        conteúdo: "Declaração atualizada"
      }
    }
    assert_response :redirect
    assert_match /activities\/#{@activity.slug}/, response.location
  end

  test "should destroy statement when authenticated" do
    statement = statements(:one)
    assert_difference('Statement.count', -1) do
      delete activity_statement_path(@activity, statement)
    end
    assert_response :redirect
    assert_match /activities\/#{@activity.slug}/, response.location
  end

  test "should not allow access without authentication" do
    sign_out @user
    post activity_statements_path(@activity), params: { 
      statement: { 
        conteúdo: "Test statement"
      }
    }
    assert_redirected_to new_user_session_path
  end
end
