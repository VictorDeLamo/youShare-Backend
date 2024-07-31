Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(
    Rails.application.credentials.dig(:aws, :access_key_id),
    Rails.application.credentials.dig(:aws, :secret_access_key),
    Rails.application.credentials.dig(:aws, :session_token)
  )
})
