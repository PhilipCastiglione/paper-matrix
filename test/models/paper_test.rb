# == Schema Information
#
# Table name: papers
#
#  id           :integer          not null, primary key
#  authors      :string
#  auto_summary :text
#  read         :boolean          default(FALSE)
#  title        :string
#  url          :string
#  year         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require "test_helper"

class PaperTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
