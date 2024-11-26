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
#  year         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Paper < ApplicationRecord
  has_rich_text :notes
  has_one_attached :source_file

  validate :creation_requirements, on: :create

  def fetch_source_file_from_url!
    return if url.blank? || source_file.attached?

    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    # TODO: we should check the content type and only allow certain types
    if response.is_a?(Net::HTTPSuccess)
      source_file.attach(io: StringIO.new(response.body), filename: File.basename(uri.path))
      true
    else
      errors.add(:base, "Unable to fetch source file from url")
      false
    end
  end

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
