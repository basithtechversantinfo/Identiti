require 'test_helper'

class TemplateThemesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template_theme = template_themes(:one)
  end

  test "should get index" do
    get template_themes_url
    assert_response :success
  end

  test "should get new" do
    get new_template_theme_url
    assert_response :success
  end

  test "should create template_theme" do
    assert_difference('TemplateTheme.count') do
      post template_themes_url, params: { template_theme: { industry_id: @template_theme.industry_id, title: @template_theme.title } }
    end

    assert_redirected_to template_theme_url(TemplateTheme.last)
  end

  test "should show template_theme" do
    get template_theme_url(@template_theme)
    assert_response :success
  end

  test "should get edit" do
    get edit_template_theme_url(@template_theme)
    assert_response :success
  end

  test "should update template_theme" do
    patch template_theme_url(@template_theme), params: { template_theme: { industry_id: @template_theme.industry_id, title: @template_theme.title } }
    assert_redirected_to template_theme_url(@template_theme)
  end

  test "should destroy template_theme" do
    assert_difference('TemplateTheme.count', -1) do
      delete template_theme_url(@template_theme)
    end

    assert_redirected_to template_themes_url
  end
end
