require "unit_test_case"

class PapersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @paper = papers(:one)
  end

  test "should get index" do
    get papers_url
    assert_response :success
  end

  test "should get new" do
    get new_paper_url
    assert_response :success
  end

  test "should create paper with url" do
    assert_difference("Paper.count") do
      post papers_url, params: { paper: { url: "https://academic-papers.com/brains.pdf" } }
    end

    assert_redirected_to paper_url(Paper.last)
  end

  test "should create paper with source file upload" do
    assert_difference("Paper.count") do
      post papers_url, params: { paper: { source_file: fixture_file_upload("brains.pdf") } }
    end

    assert_redirected_to paper_url(Paper.last)
  end

  test "should fetch_source_file" do
    uri = URI.parse(@paper.url)
    stub_request(:get, uri.to_s).to_return(body: File.read("test/fixtures/files/brains.pdf"))
    post fetch_source_file_url(@paper)
    assert_redirected_to paper_url(@paper)
  end

  test "should generate_auto_summary" do
    @paper.stub(:generate_auto_summary!, true) do
      post generate_auto_summary_url(@paper)
      assert_redirected_to paper_url(@paper)
    end
  end

  test "should show paper" do
    get paper_url(@paper)
    assert_response :success
  end

  test "should get edit" do
    get edit_paper_url(@paper)
    assert_response :success
  end

  test "should update paper" do
    patch paper_url(@paper), params: { paper: { authors: @paper.authors, auto_summary: @paper.auto_summary, notes: @paper.notes, read: @paper.read, title: @paper.title, url: @paper.url, year: @paper.year } }
    assert_redirected_to paper_url(@paper)
  end

  test "should destroy paper" do
    assert_difference("Paper.count", -1) do
      delete paper_url(@paper)
    end

    assert_redirected_to papers_url
  end
end
