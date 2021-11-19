require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  setup do
    @survey = surveys(:one)
  end

  test "visiting the index" do
    visit surveys_url
    assert_selector "h1", text: "Surveys"
  end

  test "creating a Survey" do
    visit surveys_url
    click_on "New Survey"

    fill_in "Delivery end at", with: @survey.delivery_end_at
    fill_in "Delivery start at", with: @survey.delivery_start_at
    fill_in "Delivery time", with: @survey.delivery_time
    fill_in "Email from", with: @survey.email_from
    fill_in "Email sender", with: @survey.email_sender
    fill_in "Email subject", with: @survey.email_subject
    fill_in "Group", with: @survey.group_id
    fill_in "Title", with: @survey.title
    click_on "Create Survey"

    assert_text "Survey was successfully created"
    click_on "Back"
  end

  test "updating a Survey" do
    visit surveys_url
    click_on "Edit", match: :first

    fill_in "Delivery end at", with: @survey.delivery_end_at
    fill_in "Delivery start at", with: @survey.delivery_start_at
    fill_in "Delivery time", with: @survey.delivery_time
    fill_in "Email from", with: @survey.email_from
    fill_in "Email sender", with: @survey.email_sender
    fill_in "Email subject", with: @survey.email_subject
    fill_in "Group", with: @survey.group_id
    fill_in "Title", with: @survey.title
    click_on "Update Survey"

    assert_text "Survey was successfully updated"
    click_on "Back"
  end

  test "destroying a Survey" do
    visit surveys_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Survey was successfully destroyed"
  end
end
