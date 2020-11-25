# frozen_string_literal: true

require 'test_helper'

describe CategoriesController do
  let (:user1) { users(:user_1) }
  let (:category_hash) do
    {
        category: {
            name: "pretty",
            description: "Wow it's pretty"
        }

    }
  end
  describe "index" do
    it 'responds with a success code' do
      get categories_path
      must_respond_with :success
    end
  end
  describe "create" do
    it "saves a valid category and returns a redirect code" do
      perform_login(users(:user_1))
      expect {
        post categories_path, params: category_hash
      }.must_differ "Category.count", 1
      must_respond_with :redirect
    end
    it "won't allow access if not logged in" do
    expect {
      post categories_path, params: category_hash
    }.wont_change "Category.count"
    must_respond_with :redirect
    end
  end
  describe "show" do
    it "responds with a success code if there is a category" do
      pretty = Category.create(name: "pretty", description: "is a star")

      get category_path(pretty.id)

      must_respond_with :success

    end
    it "responds with a redirect with an invalid category id" do
      invalid_id = 0000

      get category_path(invalid_id)

      must_respond_with :redirect

    end
  end
  describe "new" do
    it "redirects to makes a new category" do
      perform_login(users(:user_1))
      get new_category_path

      must_respond_with :success
    end
  end
end
