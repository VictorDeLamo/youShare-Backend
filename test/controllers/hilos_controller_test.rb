require "test_helper"

class HilosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hilo = hilos(:one)
  end

  test "should get index" do
    get hilos_url
    assert_response :success
  end

  test "should get new" do
    get new_hilo_url
    assert_response :success
  end

  test "should create hilo" do
    assert_difference("Hilo.count") do
      post hilos_url, params: { hilo: { title: @hilo.title, content: @hilo.content } }
    end

    assert_redirected_to hilo_url(Hilo.last)
  end

  test "should show hilo" do
    get hilo_url(@hilo)
    assert_response :success
  end

  test "should get edit" do
    get edit_hilo_url(@hilo)
    assert_response :success
  end

  test "should update hilo" do
    patch hilo_url(@hilo), params: { hilo: { title: @hilo.title, content: @hilo.content } }
    assert_redirected_to hilo_url(@hilo)
  end

  test "should destroy hilo" do
    assert_difference("Hilo.count", -1) do
      delete hilo_url(@hilo)
    end

    assert_redirected_to hilos_url
  end
end
