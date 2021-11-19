require "application_system_test_case"

class Admin::LabelTemplatesTest < ApplicationSystemTestCase
  setup do
    @admin_label_template = admin_label_templates(:one)
  end

  test "visiting the index" do
    visit admin_label_templates_url
    assert_selector "h1", text: "Admin/Label Templates"
  end

  test "creating a Label template" do
    visit admin_label_templates_url
    click_on "New Admin/Label Template"

    fill_in "Account", with: @admin_label_template.account
    fill_in "Description", with: @admin_label_template.description
    fill_in "Title", with: @admin_label_template.title
    click_on "Create Label template"

    assert_text "Label template was successfully created"
    click_on "Back"
  end

  test "updating a Label template" do
    visit admin_label_templates_url
    click_on "Edit", match: :first

    fill_in "Account", with: @admin_label_template.account
    fill_in "Description", with: @admin_label_template.description
    fill_in "Title", with: @admin_label_template.title
    click_on "Update Label template"

    assert_text "Label template was successfully updated"
    click_on "Back"
  end

  test "destroying a Label template" do
    visit admin_label_templates_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Label template was successfully destroyed"
  end
end
