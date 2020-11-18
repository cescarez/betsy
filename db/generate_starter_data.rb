require 'faker'
require 'date'
require 'csv'

# run this script in order to replace it and generate a new one
# run using the command:
# $ ruby db/generate_starter_data.rb
# if satisfied with the new <name>-seeds.csv file, recreate the db with:
# $ rails db:reset

CSV.open('db/products-seeds.csv', 'w', write_headers: true,
                                       headers: %w[category name price description]) do |csv|
  25.times do
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
      'failure'
           end
    price = rand(100..1_000_000)
    description = Faker::ChuckNorris.unique.fact

    csv << [category, name, price, description]
  end
end

CSV.open('db/users-seeds.csv', 'w', write_headers: true,
                                    headers: %w[username email is_authenticated]) do |csv|
  25.times do
    username = Faker::Games::Minecraft.unique.mob
    email = Faker::Internet.unique.email
    is_authenticated = [true, false].sample

    csv << [username, email, is_authenticated]
  end
end
