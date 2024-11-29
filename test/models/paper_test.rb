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
    assert_includes paper.errors[:base], "Source file must be a PDF"
  end

  test "url must end with .pdf" do
    paper = Paper.new(url: "http://example.com/paper.txt")
    assert_not paper.valid?
    assert_includes paper.errors[:base], "Url must end with .pdf"
  end

  test "url must be a valid URL" do
    paper = Paper.new(url: "not a url")
    assert_not paper.valid?
    assert_includes paper.errors[:base], "Url is invalid"
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
    assert_includes paper.errors[:base], "Url must be present and end with .pdf"
  end

  test "fetch source file from url fails when url does not end with .pdf" do
    paper = Paper.new(url: "http://example.com/paper.txt")
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:base], "Url must be present and end with .pdf"
  end

  test "fetch source file from url fails when source file is already attached" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    paper.source_file.attach(io: StringIO.new("file"), filename: "file.pdf")
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:base], "Source file must not already be attached"
  end

  test "fetch source file from url fails when response is not successful" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    stub_request(:get, "http://example.com/paper.pdf").to_return(status: 404)
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:base], "Unable to fetch source file from url"
  end

  test "fetch source file from url fails when unable to fetch" do
    paper = Paper.new(url: "http://example.com/paper.pdf")
    stub_request(:get, "http://example.com/paper.pdf").to_raise(Errno::ECONNREFUSED)
    assert_not paper.fetch_source_file_from_url!
    assert_includes paper.errors[:base], "Unable to fetch source file from url: Connection refused - Exception from WebMock"
  end
end
