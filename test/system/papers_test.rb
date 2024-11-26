require "application_system_test_case"

class PapersTest < ApplicationSystemTestCase
  setup do
    @paper = papers(:one)
  end

  test "visiting the index" do
    visit papers_url
    assert_selector "h1", text: "Papers"
  end

  test "should create paper" do
    visit papers_url
    click_on "New paper"

    fill_in "Authors", with: @paper.authors
    fill_in "Auto summary", with: @paper.auto_summary
    fill_in "Notes", with: @paper.notes
    check "Read" if @paper.read
    fill_in "Title", with: @paper.title
    fill_in "Url", with: @paper.url
    fill_in "Year", with: @paper.year
    click_on "Create Paper"

    assert_text "Paper was successfully created"
    click_on "Back"
  end

  test "should update Paper" do
    visit paper_url(@paper)
    click_on "Edit this paper", match: :first

    fill_in "Authors", with: @paper.authors
    fill_in "Auto summary", with: @paper.auto_summary
    fill_in "Notes", with: @paper.notes
    check "Read" if @paper.read
    fill_in "Title", with: @paper.title
    fill_in "Url", with: @paper.url
    fill_in "Year", with: @paper.year
    click_on "Update Paper"

    assert_text "Paper was successfully updated"
    click_on "Back"
  end

  test "should destroy Paper" do
    visit paper_url(@paper)
    click_on "Destroy this paper", match: :first

    assert_text "Paper was successfully destroyed"
  end
end
