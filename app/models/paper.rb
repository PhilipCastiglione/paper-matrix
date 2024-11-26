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

  validate :creation_requirements, on: :create

  private

  def creation_requirements
    if url.blank?
      # TODO: we will add support for creation with a file upload in the future
      errors.add(:base, "Url is required")
    end

    begin
      uri = URI.parse(url)
      errors.add(:base, "Url is invalid") unless (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && !uri.host.nil?
    rescue URI::InvalidURIError
      errors.add(:base, "Url is invalid")
    end
  end
end
