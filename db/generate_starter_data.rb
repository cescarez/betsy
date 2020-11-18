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
    category = %w[star planet].sample
    name = if category == 'star'
      Faker::Space.unique.star
           elsif category == 'planet'
      Faker::Space.unique.planet
           else
      'failure'
           end
    price = rand(100..1_000_000)
    description = Faker::ChuckNorris.unique.fact

    csv << [category, name, price, description]
  end
end

CSV.open('db/users-seeds.csv', 'w', write_headers: true,
                                    headers: %w[username email authed]) do |csv|
  25.times do
    username = Faker::Games::Minecraft.unique.mob
    email = Faker::Internet.unique.email
    authed = [true, false].sample

    csv << [username, email, authed]
  end
end
