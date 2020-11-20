# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

USERS_FILE = Rails.root.join('db', 'users-seeds.csv')
puts "Loading raw data from #{USERS_FILE}"

user_failures = []
CSV.foreach(USERS_FILE, :headers => true) do |row|
  user = User.new
  user.uid = row['uid']
  user.username = row['username']
  user.name = row['name']
  user.provider = row['provider']
  user.email = row['email']
  user.is_authenticated = row['is_authenticated']
  user.created_at = row['created_at']
  user.order_id = row['order_id']
  successful = user.save
  if !successful
    user_failures << user
    puts "Failed to save user: #{user.inspect}"
  else
    puts "Created user: #{user.inspect}"
  end
end

puts "Added #{User.count} user records"
puts "#{user_failures.length} users failed to save"

PRODUCTS_FILE = Rails.root.join('db', 'products-seeds.csv')

puts "Loading raw data from #{PRODUCTS_FILE}"
product_failures = []
CSV.foreach(PRODUCTS_FILE, :headers => true) do |row|
  product = Product.new
  product.id = row['id']
  product.category = row['category']
  product.name = row['name']
  product.price = row['price']
  product.description = row['description']
  product.inventory = row['inventory']
  product.user_id = row['user_id']
  #product.order_id = row['order_id']
  successful = product.save
  if !successful
    product_failures << product
    puts "Failed to save products: #{product.inspect}"
  else
    puts "Created products: #{product.inspect}"
  end
end

puts "Added #{Product.count} products records"
puts "#{product_failures.length} products failed to save"

puts "Manally resetting PK sequence on each table"

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

puts "done"


# Since we set the primary key (the ID) manually on each of the
# tables, we've got to tell postgres to reload the latest ID
# values. Otherwise when we create a new record it will try
# to start at ID 1, which will be a conflict.
puts "Manually resetting PK sequence on each table"
ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end

puts "done"

