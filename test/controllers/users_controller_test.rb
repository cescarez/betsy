require "test_helper"

describe UsersController do

describe 'Create' do

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

 it "will flash error if the user is not successfully logged in" do
   invalid_auth_hash = {
       uid: "uid",
       provider: "provider",
       info: {
           name: nil,
           email: "email",
           image: "No photo"
       }
   }
   OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(invalid_auth_hash)

   get omniauth_callback_path(:github)

   assert_equal "Could not create user account Username can't be blank", flash[:error]
 end

end

describe 'Current' do

  it "can return the page if the user is logged in" do
    perform_login(users(:user_1))
    get current_user_path
    must_respond_with :success
  end


  it "redirects us back if the user is not logged in" do
    get current_user_path
    expect(flash[:error]).must_equal "You must log in first to view this page 🙃"
    must_respond_with :redirect
    must_redirect_to root_path
  end

end

describe 'Logout' do

  it "can logout an existing user" do
    perform_login(users(:user_1))
    expect(session[:user_id]).wont_be_nil
    delete logout_path, params: {}
    expect(session[:user_id]).must_be_nil
    must_respond_with :redirect
    must_redirect_to root_path
  end

  it "will flash error if not logged in and redirect to root_path" do
    delete logout_path, params: {}
    expect(session[:user_id]).must_be_nil
    must_respond_with :redirect
    must_redirect_to root_path
  end

end

describe "Index" do

  it "can access the index" do
    get users_path
    must_respond_with :success
  end

end

describe "Show" do

  it "will respond with success if user id is incorrect" do
    get user_path(User.first.id)
    must_respond_with :success
  end

  it "will respond with a 404 error if user id is incorrect" do
    get user_path(-1)
    must_respond_with 404
  end

end

end


