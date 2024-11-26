# == Schema Information
#
# Table name: papers
#
#  id           :integer          not null, primary key
#  authors      :string
#  auto_summary :text
#  notes        :text
#  read         :boolean          default(FALSE)
#  title        :string
#  url          :string
#  year         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Paper < ApplicationRecord
  has_rich_text :notes
end
