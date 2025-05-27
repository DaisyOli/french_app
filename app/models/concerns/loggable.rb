module Loggable
  extend ActiveSupport::Concern

  included do
    after_create :log_creation
    after_update :log_update
    after_destroy :log_destruction
  end

  private

  def log_creation
    Rails.logger.info({
      event: 'record_created',
      model: self.class.name,
      id: self.id,
      attributes: loggable_attributes,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  def log_update
    if saved_changes.any?
      Rails.logger.info({
        event: 'record_updated',
        model: self.class.name,
        id: self.id,
        changes: saved_changes.except('updated_at'),
        timestamp: Time.current.iso8601
      }.to_json)
    end
  end

  def log_destruction
    Rails.logger.info({
      event: 'record_destroyed',
      model: self.class.name,
      id: self.id,
      timestamp: Time.current.iso8601
    }.to_json)
  end

  def loggable_attributes
    # Override in models to specify which attributes to log
    attributes.except('created_at', 'updated_at', 'encrypted_password')
  end
end 