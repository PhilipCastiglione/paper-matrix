# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email_address should be normalized" do
    user = User.new(email_address: " LoL@examPLE.com  ", password: "password", password_confirmation: "password")
    assert user.valid?
    assert_equal "lol@example.com", user.email_address
  end
end
