require 'test_helper'

class Groups::Surveys::StepControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get groups_surveys_step_index_url
    assert_response :success
  end

end
