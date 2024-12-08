OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.openai[:access_token]
  config.log_errors = true
end
