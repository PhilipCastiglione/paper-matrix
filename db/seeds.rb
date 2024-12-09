email_address = Rails.application.credentials.user[:email]
password = Rails.application.credentials.user[:password]

unless User.exists?(email_address: email_address)
  user = User.new(email_address: email_address)
  user.password = password
  user.password_confirmation = password
  user.save!
end
