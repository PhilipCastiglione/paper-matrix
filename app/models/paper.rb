require "net/http"

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
class Paper < ApplicationRecord
  has_rich_text :notes
  has_one_attached :source_file

  default_scope { order(year: :desc, authors: :asc, title: :asc) }

  validates :title, uniqueness: true, allow_blank: true
  validates :url, uniqueness: true, allow_blank: true
  validate :creation_requirements, on: :create

  def fetch_source_file_from_url!
    return if url.blank? || !url.end_with?(".pdf") || source_file.attached?

    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      source_file.attach(io: StringIO.new(response.body), filename: File.basename(uri.path))
      true
    else
      errors.add(:base, "Unable to fetch source file from url")
      false
    end
  rescue URI::InvalidURIError, Errno::ENOENT, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, OpenSSL::SSL::SSLError => e
    errors.add(:base, "Unable to fetch source file from url: #{e.message}")
    false
  end

  private

  def creation_requirements
    if url.blank? && !source_file.attached?
      errors.add(:base, "Url or source file is required")
    end

    if url.present? && source_file.attached?
      errors.add(:base, "Only one of url or source file can be present")
    end

    if source_file.attached?
      unless source_file.blob.content_type.start_with?("application/pdf")
        errors.add(:base, "Source file must be a PDF")
      end
    end

    if url.present?
      unless url.end_with?(".pdf")
        errors.add(:base, "Url must end with .pdf")
      end

      begin
        uri = URI.parse(url)
        if uri.host.nil? || !(uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS))
          errors.add(:base, "Url is invalid")
        end
      rescue URI::InvalidURIError
        errors.add(:base, "Url is invalid")
      end
    end
  end
end
