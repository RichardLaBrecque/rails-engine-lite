# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Item request Specs' do
  it 'returns all items as json' do
    merchants = create_list(:merchant, 4)
    items = merchants.map do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    get '/api/v1/items'
    expect(response).to be_successful
    items = JSON.parse(response.body, symbolize_names: true)
    # binding.pry
    expect(items[:data].count).to eq(8)
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

  it 'returns a single item' do
    merchants = create_list(:merchant, 4)
    merchant_items = merchants.each do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    get "/api/v1/items/#{merchant_items.first.items.first.id}"
    expect(response).to be_successful
    item = JSON.parse(response.body, symbolize_names: true)
    expect(item[:data].count).to eq(3)
    expect(item[:data]).to be_a Hash
    expect(item[:data]).to have_key(:type)
    expect(item[:data]).to have_key(:attributes)
    expect(item[:data]).to have_key(:id)
    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes]).to have_key(:unit_price)
  end

  it 'creates an item' do
    merchants = create_list(:merchant, 4)
    post '/api/v1/items', params: { item: { "name": 'value1',
                                            "description": 'value2',
                                            "unit_price": 100.99,
                                            "merchant_id": merchants.first.id } }
    expect(response).to be_successful
    created = JSON.parse(response.body, symbolize_names: true)
    expect(created).to have_key(:data)
    expect(created[:data]).to have_key(:id)
    expect(created[:data]).to have_key(:type)
    expect(created[:data]).to have_key(:attributes)
    expect(created[:data][:type]).to eq('item')
    expect(created[:data][:attributes]).to have_key(:name)
    expect(created[:data][:attributes]).to have_key(:description)
    expect(created[:data][:attributes]).to have_key(:unit_price)
    expect(created[:data][:attributes]).to have_key(:merchant_id)
  end

  it 'destorys an item' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    delete "/api/v1/items/#{merchants.first.items.first.id}"
    expect(response).to be_successful
    expect(response.body).to eq(' ')
  end

  it 'updates an item' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    starting_item = merchants.first.items.first
    patch "/api/v1/items/#{starting_item.id}", params: { item: { "name": 'value1',
                                                                 "description": 'value2',
                                                                 "unit_price": 100.99 } }
    updated = JSON.parse(response.body, symbolize_names: true)
    expect(updated[:data][:id].to_i).to eq(starting_item.id)
    expect(updated[:data][:attributes][:name]).to eq('value1')
    expect(updated[:data][:attributes][:description]).to eq('value2')
    expect(updated[:data][:attributes][:unit_price]).to eq(100.99)
  end

  it 'it knows an items merchant' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: Faker::Lorem.word,
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    starting_item = merchants.first.items.first
    get "/api/v1/items/#{starting_item.id}/merchant"
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant).to have_key(:data)
    expect(merchant[:data]).to be_a Hash
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq('merchant')
    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
  end

  it 'can find all items matching a name search' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: 'One',
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) },
                             { name: 'Two',
                               description: Faker::Lorem.sentence,
                               unit_price: Faker::Number.decimal(l_digits: 2) }])
    end
    get '/api/v1/items/find_all', params: { "name": 'On' }
    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(4)
    expect(items[:data].first[:attributes][:name]).to eq('One')
  end
  it 'can find all items matching a min and max price' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: 'One',
                               description: Faker::Lorem.sentence,
                               unit_price: 10 },
                             { name: 'Two',
                               description: Faker::Lorem.sentence,
                               unit_price: 20 },
                             { name: 'Three',
                               description: Faker::Lorem.sentence,
                               unit_price: 30 }])
    end
    get '/api/v1/items/find_all', params: { "min_price": 15, "max_price": 25 }
    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(4)
  end
  it 'can find all items matching a min price' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: 'One',
                               description: Faker::Lorem.sentence,
                               unit_price: 10 },
                             { name: 'Two',
                               description: Faker::Lorem.sentence,
                               unit_price: 20 },
                             { name: 'Three',
                               description: Faker::Lorem.sentence,
                               unit_price: 30 }])
    end
    get '/api/v1/items/find_all', params: { "min_price": 20 }
    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(8)
  end
  it 'can find all items matching a max price' do
    merchants = create_list(:merchant, 4)
    merchants_items = merchants.map do |merchant|
      merchant.items.create([{ name: 'One',
                               description: Faker::Lorem.sentence,
                               unit_price: 10 },
                             { name: 'Two',
                               description: Faker::Lorem.sentence,
                               unit_price: 20 },
                             { name: 'Three',
                               description: Faker::Lorem.sentence,
                               unit_price: 30 }])
    end
    get '/api/v1/items/find_all', params: { "max_price": 15 }
    items = JSON.parse(response.body, symbolize_names: true)
    expect(items[:data].count).to eq(4)
  end
end
