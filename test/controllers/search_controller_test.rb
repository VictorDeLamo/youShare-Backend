require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get buscar" do
    get search_buscar_url
    assert_response :success
  end
end
