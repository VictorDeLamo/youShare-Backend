require "application_system_test_case"

class HilosTest < ApplicationSystemTestCase
  setup do
    @hilo = hilos(:one)
  end

  test "visiting the index" do
    visit hilos_url
    assert_selector "h1", text: "Hilos"
  end

  test "should create hilo" do
    visit hilos_url
    click_on "New hilo"

    fill_in "Author", with: @hilo.author
    fill_in "Content", with: @hilo.content
    click_on "Create Hilo"

    assert_text "Hilo was successfully created"
    click_on "Back"
  end

  test "should update Hilo" do
    visit hilo_url(@hilo)
    click_on "Edit this hilo", match: :first

    fill_in "Author", with: @hilo.author
    fill_in "Content", with: @hilo.content
    click_on "Update Hilo"

    assert_text "Hilo was successfully updated"
    click_on "Back"
  end

  test "should destroy Hilo" do
    visit hilo_url(@hilo)
    click_on "Destroy this hilo", match: :first

    assert_text "Hilo was successfully destroyed"
  end
end
