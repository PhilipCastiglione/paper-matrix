require "unit_test_case"

class PapersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @paper = papers(:one)
  end

  test "should get index" do
    get papers_url
    assert_response :success
  end

  test "should get new when authenticated" do
    sign_in(users(:one))

    get new_paper_url
    assert_response :success
  end

  test "should not get new when not authenticated" do
    get new_paper_url
    assert_redirected_to new_session_url
  end

  test "should create paper with url when authenticated" do
    sign_in(users(:one))

    assert_difference("Paper.count") do
      post papers_url, params: { paper: { url: "https://academic-papers.com/brains.pdf" } }
    end

    assert_redirected_to paper_url(Paper.last)
  end

  test "should not create paper with url when not authenticated" do
    assert_no_difference("Paper.count") do
      post papers_url, params: { paper: { url: "https://academic-papers.com/brains.pdf" } }
    end

    assert_redirected_to new_session_url
  end

  test "should create paper with source file upload when authenticated" do
    sign_in(users(:one))

    assert_difference("Paper.count") do
      post papers_url, params: { paper: { source_file: fixture_file_upload("brains.pdf") } }
    end

    assert_redirected_to paper_url(Paper.last)
  end

  test "should fetch_source_file when authenticated" do
    sign_in(users(:one))

    uri = URI.parse(@paper.url)
    stub_request(:get, uri.to_s).to_return(body: File.read("test/fixtures/files/brains.pdf"))
    post fetch_source_file_url(@paper)
    assert_redirected_to paper_url(@paper)
  end

  test "should not fetch_source_file when not authenticated" do
    post fetch_source_file_url(@paper)
    assert_redirected_to new_session_url
  end

  test "should generate_auto_summary when authenticated" do
    sign_in(users(:one))

    @paper.stub(:generate_auto_summary!, true) do
      post generate_auto_summary_url(@paper)
      assert_redirected_to paper_url(@paper)
    end
  end

  test "should not generate_auto_summary when not authenticated" do
    post generate_auto_summary_url(@paper)
    assert_redirected_to new_session_url
  end

  test "should show paper" do
    get paper_url(@paper)
    assert_response :success
  end

  test "should get edit when authenticated" do
    sign_in(users(:one))

    get edit_paper_url(@paper)
    assert_response :success
  end

  test "should not get edit when not authenticated" do
    get edit_paper_url(@paper)
    assert_redirected_to new_session_url
  end

  test "should update paper when authenticated" do
    sign_in(users(:one))

    patch paper_url(@paper), params: { paper: { authors: @paper.authors, auto_summary: @paper.auto_summary, notes: @paper.notes, read: @paper.read, title: @paper.title, url: @paper.url, year: @paper.year } }
    assert_redirected_to paper_url(@paper)
  end

  test "should not update paper when not authenticated" do
    patch paper_url(@paper), params: { paper: { authors: @paper.authors, auto_summary: @paper.auto_summary, notes: @paper.notes, read: @paper.read, title: @paper.title, url: @paper.url, year: @paper.year } }
    assert_redirected_to new_session_url
  end

  test "should destroy paper when authenticated" do
    sign_in(users(:one))

    assert_difference("Paper.count", -1) do
      delete paper_url(@paper)
    end

    assert_redirected_to papers_url
  end

  test "should not destroy paper when not authenticated" do
    assert_no_difference("Paper.count") do
      delete paper_url(@paper)
    end

    assert_redirected_to new_session_url
  end
end
