require 'test_helper'

class PersonaDisplayTypesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get persona_display_types_show_url
    assert_response :success
  end

end
