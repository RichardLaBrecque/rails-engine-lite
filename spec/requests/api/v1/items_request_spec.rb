require 'rails_helper'

RSpec.describe 'Item request Specs' do
  it 'returns all items as json' do
    merchants = create_list(:merchant, 4)
    items = merchants.map do |merchant|
      merchant.items.create([{name: Faker::Lorem.word,
                      description: Faker::Lorem.sentence,
                      unit_price:Faker::Number.decimal(l_digits: 2)},
                      {name: Faker::Lorem.word,
                      description: Faker::Lorem.sentence,
                      unit_price:Faker::Number.decimal(l_digits: 2)}]
    )
    end
    binding.pry
    get '/api/vi/items'
    expect(response).to be_successful
    items = JSON.parse(response.body, symbolize_names: true)
  end
end
