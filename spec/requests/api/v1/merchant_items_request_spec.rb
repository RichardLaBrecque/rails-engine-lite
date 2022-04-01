# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Merchant items request Specs' do
  it 'returns all of a Merchants items as json' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    get "/api/v1/merchants/#{merchants.first.id}/items"
    expect(response).to be_successful
    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(2)
    expect(items[:data]).to be_a Array
    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item).to have_key(:type)
      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes]).to have_key(:unit_price)
    end
  end
end
