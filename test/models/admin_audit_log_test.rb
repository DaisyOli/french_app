require "test_helper"

class AdminAuditLogTest < ActiveSupport::TestCase
  def setup
    @log = AdminAuditLog.new(admin: users(:one), action: "delete_teacher", target_description: "prof@example.com")
  end

  test "should be valid with valid attributes" do
    assert @log.valid?
  end

  test "should require admin" do
    @log.admin = nil
    assert_not @log.valid?
  end

  test "should require action" do
    @log.action = nil
    assert_not @log.valid?
  end

  test "should require target_description" do
    @log.target_description = nil
    assert_not @log.valid?
  end
end
