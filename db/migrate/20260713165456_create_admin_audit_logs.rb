class CreateAdminAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_audit_logs do |t|
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :target_description, null: false
      t.text :details

      t.timestamps
    end
  end
end
