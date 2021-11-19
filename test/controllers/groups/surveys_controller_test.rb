require 'test_helper'

class Groups::SurveysControllerTest < ActionDispatch::IntegrationTest
  test "should get all" do
    get groups_surveys_all_url
    assert_response :success
  end

end
