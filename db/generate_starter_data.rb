# frozen_string_literal: true

require 'faker'
require 'date'
require 'csv'

# run this script in order to replace it and generate a new one
# run using the command:
# $ ruby db/generate_starter_data.rb
# if satisfied with the new <name>-seeds.csv file, recreate the db with:
# $ rails db:reset

CSV.open('db/categories-seeds.csv', 'w', write_headers: true,
         headers: %w[name description]) do |csv|
  categories = %w[star planet moon galaxy nebula]
  5.times do |num|
    name = categories[num]
    description = Faker::ChuckNorris.unique.fact
    csv << [name, description]
  end
end

CSV.open('db/products-seeds.csv', 'w', write_headers: true,
                                       headers: %w[name price description inventory user_id order_id retire]) do |csv|
  10.times do |num|
    name = Faker::Space.unique.star
    price = rand(100.0..1_000_000.0)
    description = Faker::ChuckNorris.unique.fact
    inventory = rand(1..10)
    user_id = num + 1
    order_id = num + 1
    retire = false
    csv << [name, price, description, inventory, user_id, order_id, retire]
  end
  15.times do |num|
    name = Faker::Space.unique.moon
    price = rand(100.0..1_000_000.0)
    description = Faker::ChuckNorris.unique.fact
    inventory = rand(1..10)
    user_id = num + 1
    order_id = num + 1
    retire = false
    csv << [name, price, description, inventory, user_id, order_id, retire]
  end
end

CSV.open('db/users-seeds.csv', 'w', write_headers: true,
                                    headers: %w[uid username name provider email is_authenticated created_at order_id]) do |csv|
  25.times do |num|
    uid = num + 100
    username = Faker::Games::Minecraft.unique.mob
    name = Faker::Name.unique.name
    provider = 'github'
    email = Faker::Internet.unique.email
    is_authenticated = [true, false].sample
    created_at = Faker::Date.between(from: '2019-09-23', to: '2020-11-23')
    order_id = num + 2

    csv << [uid, username, name, provider, email, is_authenticated, created_at, order_id]
  end
end
