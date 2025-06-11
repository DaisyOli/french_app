class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def show
    health_status = {
      status: 'ok',
      timestamp: Time.current.iso8601,
      checks: {}
    }
    
    begin
      # Verificar conexão com banco de dados
      ActiveRecord::Base.connection.execute('SELECT 1')
      health_status[:checks][:database] = { status: 'ok' }
    rescue => e
      health_status[:status] = 'error'
      health_status[:checks][:database] = { 
        status: 'error', 
        message: e.message 
      }
    end
    
    begin
      # Verificar conexão com Redis
      Rails.cache.fetch('health_check', expires_in: 1.minute) { 'ok' }
      health_status[:checks][:redis] = { status: 'ok' }
    rescue => e
      health_status[:status] = 'error'
      health_status[:checks][:redis] = { 
        status: 'error', 
        message: e.message 
      }
    end
    
    status_code = health_status[:status] == 'ok' ? 200 : 503
    render json: health_status, status: status_code
  end
end 