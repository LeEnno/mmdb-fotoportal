require 'test_helper'

class GalleryControllerTest < ActionController::TestCase
  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show_folder" do
    get :show_folder
    assert_response :success
  end

  test "should get show_picture" do
    get :show_picture
    assert_response :success
  end

end
