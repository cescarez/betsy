require 'faker'
require 'date'
require 'csv'

# run this script in order to replace it and generate a new one
# run using the command:
# $ ruby db/generate_starter_data.rb
# if satisfied with the new <name>-seeds.csv file, recreate the db with:
# $ rails db:reset

CSV.open('db/products-seeds.csv', 'w', write_headers: true,
                                       headers: %w[category name price description inventory user_id order_id]) do |csv|
  25.times do |num|
    category = %w[star planet moon galaxy nebula].sample
    name = if category == 'star'
      Faker::Space.unique.star
           elsif category == 'planet'
      Faker::Space.unique.planet
           elsif category == 'moon'
             Faker::Space.unique.moon
           elsif category == 'galaxy'
             Faker::Space.unique.galaxy
           elsif category == 'nebula'
             Faker::Space.unique.nebula
           else
             nil
           end
    price = rand(100.0..1_000_000.0)
    description = Faker::ChuckNorris.unique.fact
    inventory = rand(1..10)
    user_id = num + 1
    order_id = num + 1
    csv << [category, name, price, description, inventory, user_id, order_id]
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
