require "application_system_test_case"

class TemplateThemesTest < ApplicationSystemTestCase
  setup do
    @template_theme = template_themes(:one)
  end

  test "visiting the index" do
    visit template_themes_url
    assert_selector "h1", text: "Template Themes"
  end

  test "creating a Template theme" do
    visit template_themes_url
    click_on "New Template Theme"

    fill_in "Industry", with: @template_theme.industry_id
    fill_in "Title", with: @template_theme.title
    click_on "Create Template theme"

    assert_text "Template theme was successfully created"
    click_on "Back"
  end

  test "updating a Template theme" do
    visit template_themes_url
    click_on "Edit", match: :first

    fill_in "Industry", with: @template_theme.industry_id
    fill_in "Title", with: @template_theme.title
    click_on "Update Template theme"

    assert_text "Template theme was successfully updated"
    click_on "Back"
  end

  test "destroying a Template theme" do
    visit template_themes_url
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Template theme was successfully destroyed"
  end
end
