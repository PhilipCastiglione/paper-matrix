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

  after_update_commit -> { broadcast_updated }

  default_scope { order(year: :desc, authors: :asc, title: :asc) }

  validates :title, uniqueness: true, allow_blank: true
  validates :url, uniqueness: true, allow_blank: true
  validate :creation_requirements, on: :create

  def fetch_source_file_from_url!
    if url.blank? || !url.end_with?(".pdf")
      errors.add(:url, "Url must be present and end with .pdf")
      return false
    end

    if source_file.attached?
      errors.add(:source_file, "Source file must not already be attached")
      return false
    end

    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      source_file.attach(io: StringIO.new(response.body), filename: File.basename(uri.path))
      true
    else
      errors.add(:url, "Unable to fetch source file from url")
      false
    end
  rescue URI::InvalidURIError, Errno::ENOENT, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::ETIMEDOUT, SocketError, OpenSSL::SSL::SSLError => e
    errors.add(:url, "Unable to fetch source file from url: #{e.message}")
    false
  end

  def generate_auto_summary!
    unless source_file.attached?
      errors.add(:source_file, "Source file must be attached")
      return false
    end

    client = OpenAI::Client.new

    # TODO: do something smarter with the pdf file
    # can we upload it to some endpoint and make it available directly?
    # for now we are sending the text content of the pdf extracted by PDF::Reader

    # client.files.upload(parameters: { file: "path/to/file.pdf", purpose: "assistants" })

    # my_file = File.open(source_file.blob.download, "rb")
    # my_file = StringIO.new(source_file.blob.download)
    # client.files.upload(parameters: { file: my_file, purpose: "assistants" })

    first_page_content = ""
    pdf_content = ""
    source_file.open do |file|
      file.binmode
      reader = PDF::Reader.new(file)
      first_page_content = reader.pages.first.text
      pdf_content = reader.pages.map(&:text).join("\n")
    end

    response = client.chat(parameters: {
      model: "gpt-4o-mini",
      messages: extraction_messages(first_page_content),
      response_format: { type: "json_object" },
      temperature: 0.2
    })
    update_fields_from_extraction(response.dig("choices", 0, "message", "content"))

    client.chat(
      parameters: {
        model: "gpt-4o",
        messages: summarization_messages(pdf_content),
        temperature: 0.4,
        stream: proc do |chunk, _bytesize|
          new_content = chunk.dig("choices", 0, "delta", "content")
          update(auto_summary: (auto_summary || "") + new_content) if new_content
        end
      }
    )

    true
  rescue OpenAI::Error, Faraday::Error => e
    errors.add(:auto_summary, "Unable to generate auto summary: #{e.message}")
    false
  end

  private

  def broadcast_updated
    broadcast_replace(
      partial: "papers/paper",
      locals: { paper: self },
      target: "paper_#{id}"
    )
  end

  def creation_requirements
    if url.blank? && !source_file.attached?
      errors.add(:base, "Url or source file is required")
    end

    if url.present? && source_file.attached?
      errors.add(:base, "Only one of url or source file can be present")
    end

    if source_file.attached?
      unless source_file.blob.content_type.start_with?("application/pdf")
        errors.add(:source_file, "Source file must be a PDF")
      end
    end

    if url.present?
      unless url.end_with?(".pdf")
        errors.add(:url, "Url must end with .pdf")
      end

      begin
        uri = URI.parse(url)
        if uri.host.nil? || !(uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS))
          errors.add(:url, "Url is invalid")
        end
      rescue URI::InvalidURIError
        errors.add(:url, "Url is invalid")
      end
    end
  end

  def extraction_messages(first_page_content)
    [
      { role: "system", content: "You are an expert at reading and summarizing academic papers. You carefully extract requested data from academic papers." },
      { role: "user", content: "Please extract the following information from the first page of an academic paper and respond with JSON:\n{\"title\":<paper_title:string>,\"authors\":<paper_authors:string>,\"year\":<publication_year:integer>}" },
      { role: "user", content: "Here is the paper \n" + first_page_content }
    ]
  end

  def update_fields_from_extraction(extracted_data)
    parsed_data = JSON.parse(extracted_data)

    new_title = parsed_data.fetch("title", nil)
    new_authors = parsed_data.fetch("authors", nil)
    new_year = parsed_data.fetch("year", nil)&.to_i

    new_data = {}
    new_data[:title] = new_title if new_title.present?
    new_data[:authors] = new_authors if new_authors.present?
    new_data[:year] = new_year if new_year.present?

    update(new_data)
  rescue Exception => e
    errors.add(:base, "Unable to extract data: #{e.message}")
  end

  def summarization_messages(pdf_content)
    [
      { role: "system", content: "You are an expert at reading and summarizing academic papers. You provide succinct but detailed summaries of academic papers highlighting the most important details. You maintain an extremely high quality bar and are detailed and thorough." },
      { role: "user", content: "Please summarize the following academic paper." },
      { role: "user", content: pdf_content }
    ]
  end
end
