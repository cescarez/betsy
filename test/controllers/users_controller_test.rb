require "test_helper"

 describe UsersController do
#   it "must get create" do
#     get users_create_url
#     must_respond_with :success
#   end
#
#   it "must get index" do
#     get users_index_url
#     must_respond_with :success
#   end
#
#   it "must get show" do
#     get users_show_url
#     must_respond_with :success
#   end
#
#   it "must get update" do
#     get users_update_url
#     must_respond_with :success
#   end
#
#   it "must get destroy" do
#     get users_destroy_url
#     must_respond_with :success
#   end
#
#   it "must get edit" do
#     get users_edit_url
#     must_respond_with :success
#   end
#
#   it "must get new" do
#     get users_new_url
#     must_respond_with :success
#   end
#

describe 'create users' do

  it 'can log in an existing user' do
    perform_login(users(:user_1))
    must_respond_with :redirect
  end

  it 'can log in a new user' do
    user_3 = User.new(
        username: 'username_3',
        provider: 'github',
        email: 'username_3@gmail.com',
        uid: '1234',
        name: 'name_3'
    )
    expect {
      perform_login(user_3)
    }.must_change 'User.count', 1
  end
end

  describe 'current' do

    it "can return the page if the user is logged in" do
      perform_login(users(:user_1))
      get current_user_path
      must_respond_with :success
    end

    it "redirects us back if the user is not logged in" do
      get current_user_path
      expect(flash[:error]).must_equal "You must be logged in to view this page"
      must_respond_with :redirect
      must_redirect_to root_path

    end
  end

  describe 'logout' do
    it "can logout an existing user" do
      perform_login(users(:user_1))
      expect(session[:user_id]).wont_be_nil
      delete logout_path, params: {}
      expect(session[:user_id]).must_be_nil
      must_respond_with :redirect
      must_redirect_to root_path
    end
  end

  describe "Guest users" do
    # it "can acces the index" do
    #   get works_path
    #   must_respond_with :success
    # end
    #
    # it "cannot access new" do
    #   get new_work_path
    #   must_redirect_to root_path
    # end
    #
    # it "tries to log out" do
    #   delete logout_path
    #   must_redirect_to root_path
    #   flash[:message].must_equal "Must log in first!"
    # end
  end
end

