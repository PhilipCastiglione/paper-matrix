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
require "unit_test_case"

class PaperTest < ActiveSupport::TestCase
  test "title must be unique" do
    Paper.create!(title: "A title", url: "http://example.com/paper.pdf")
    paper = Paper.new(title: "A title", url: "http://example.com/paper2.pdf")
    assert_not paper.valid?
  end

  test "url must be unique" do
    Paper.create!(url: "http://example.com/paper.pdf")
    paper = Paper.new(url: "http://example.com/paper.pdf")
    assert_not paper.valid?
  end

  test "url or source file is required" do
    paper = Paper.new
    assert_not paper.valid?
    assert_includes paper.errors[:base], "Url or source file is required"
  end

  test "only one of url or source file can be present" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    paper.source_file.attach(io: StringIO.new("file"), filename: "file.pdf")
    assert_not paper.valid?
    assert_includes paper.errors[:base], "Only one of url or source file can be present"
  end

  test "source file must be a PDF" do
    paper = Paper.new
    paper.source_file.attach(io: StringIO.new("file"), filename: "file.txt")
    assert_not paper.valid?
    assert_includes paper.errors[:source_file], "Source file must be a PDF"
  end

  test "url must end with .pdf" do
    paper = Paper.new(url: "http://example.com/paper.txt")
    assert_not paper.valid?
    assert_includes paper.errors[:url], "Url must end with .pdf"
  end

  test "url must be a valid URL" do
    paper = Paper.new(url: "not a url")
    assert_not paper.valid?
    assert_includes paper.errors[:url], "Url is invalid"
  end

  test "fetch source file from url succeeds when supplied " do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    stub_request(:get, "http://example.com/paper.pdf").to_return(body: "file")
    assert paper.fetch_source_file_from_url!
    assert paper.source_file.attached?
  end

  test "fetch source file from url fails when url is blank" do
    paper = Paper.new
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:url], "Url must be present and end with .pdf"
  end

  test "fetch source file from url fails when url does not end with .pdf" do
    paper = Paper.new(url: "http://example.com/paper.txt")
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:url], "Url must be present and end with .pdf"
  end

  test "fetch source file from url fails when source file is already attached" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    paper.source_file.attach(io: StringIO.new("file"), filename: "file.pdf")
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:source_file], "Source file must not already be attached"
  end

  test "fetch source file from url fails when response is not successful" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    stub_request(:get, "http://example.com/paper.pdf").to_return(status: 404)
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:url], "Unable to fetch source file from url"
  end

  test "fetch source file from url fails when unable to fetch" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    stub_request(:get, "http://example.com/paper.pdf").to_raise(Errno::ECONNREFUSED)
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:url], "Unable to fetch source file from url: Connection refused - Exception from WebMock"
  end

  test "generate auto summary fails when source file is not attached" do
    paper = Paper.new
    assert_not paper.generate_auto_summary!
    assert_includes paper.errors[:source_file], "Source file must be attached"
  end

  test "generate auto summary provides the text content of source pdf to the client" do
    paper = Paper.new
    paper.source_file.attach(io: File.open("test/fixtures/files/brains.pdf"), filename: "brains.pdf")
    paper.save

    client_mock = Minitest::Mock.new(OpenAI::Client.new)

    extraction_args = {
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are an expert at reading and summarizing academic papers. You carefully extract requested data from academic papers." },
        { role: "user", content: "Please extract the following information from the first page of an academic paper and respond with JSON:\n{\"title\":<paper title>,\"authors\":<paper authors>,\"year\":<publication year>}" },
        { role: "user", content: "Here is the paper \nDummy PDF file" }
      ],
      response_format: { type: "json_object" },
      temperature: 0.2
    }
    client_mock.expect(:chat, { choices: [ message: { content: "extracted values" } ] }, parameters: extraction_args)

    summary_args = {
      model: "gpt-4o",
      messages: [
        { role: "system", content: "You are an expert at reading and summarizing academic papers. You provide succinct but detailed summaries of academic papers highlighting the most important details. You maintain an extremely high quality bar and are detailed and thorough." },
        { role: "user", content: "Please summarize the following academic paper." },
        { role: "user", content: "Dummy PDF file" }
      ],
      temperature: 0.4
    }

    client_mock.expect(:chat, nil) do |args|
      expected_args = args[:parameters].without(:stream)
      assert_equal expected_args, summary_args
    end

    OpenAI::Client.stub(:new, client_mock) do
      paper.generate_auto_summary!
      client_mock.verify
    end
  end
end
