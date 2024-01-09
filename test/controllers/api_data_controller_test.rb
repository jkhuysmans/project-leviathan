require "test_helper"

class ApiDataControllerTest < ActionDispatch::IntegrationTest
  test "should get fetch_entries" do
    get api_data_fetch_entries_url
    assert_response :success
  end
end
