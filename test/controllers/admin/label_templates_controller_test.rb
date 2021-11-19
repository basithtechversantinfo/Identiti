require 'test_helper'

class Admin::LabelTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_label_template = admin_label_templates(:one)
  end

  test "should get index" do
    get admin_label_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_label_template_url
    assert_response :success
  end

  test "should create admin_label_template" do
    assert_difference('Admin::LabelTemplate.count') do
      post admin_label_templates_url, params: { admin_label_template: { account: @admin_label_template.account, description: @admin_label_template.description, title: @admin_label_template.title } }
    end

    assert_redirected_to admin_label_template_url(Admin::LabelTemplate.last)
  end

  test "should show admin_label_template" do
    get admin_label_template_url(@admin_label_template)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_label_template_url(@admin_label_template)
    assert_response :success
  end

  test "should update admin_label_template" do
    patch admin_label_template_url(@admin_label_template), params: { admin_label_template: { account: @admin_label_template.account, description: @admin_label_template.description, title: @admin_label_template.title } }
    assert_redirected_to admin_label_template_url(@admin_label_template)
  end

  test "should destroy admin_label_template" do
    assert_difference('Admin::LabelTemplate.count', -1) do
      delete admin_label_template_url(@admin_label_template)
    end

    assert_redirected_to admin_label_templates_url
  end
end
