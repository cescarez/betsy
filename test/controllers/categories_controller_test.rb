# frozen_string_literal: true

require 'test_helper'

describe CategoriesController do
  let (:category_hash) do
    {

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
      expect {
        post new_category_path, params: categories(:star)
      }.must_differ "Category.count", 1
      must_respond_with :redirect
    end
  end
  describe "show" do
    it "responds with a success code if there is a category" do
      star = Category.new(name: "star", description: "is a star")

      get categories_path(star.id)

      must_respond_with :success
    end
    it "responds with a redirect with an invalid category id" do
      invalid_id = 0000

      get categories_path(invalid_id)

      must_redirect_to categories_path
    end
  end
end
