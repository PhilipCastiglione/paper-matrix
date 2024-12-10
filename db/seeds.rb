email_address = Rails.application.credentials.dig(:user, :email)
password = Rails.application.credentials.dig(:user, :password)

unless User.exists?(email_address: email_address)
  user = User.new(email_address: email_address)
  user.password = password
  user.password_confirmation = password
  user.save!
end
