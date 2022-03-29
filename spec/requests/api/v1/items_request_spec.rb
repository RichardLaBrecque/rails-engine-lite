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
        merchant.items.create([{name: Faker::Lorem.word,
          description: Faker::Lorem.sentence,
          unit_price:Faker::Number.decimal(l_digits: 2)},
          {name: Faker::Lorem.word,
            description: Faker::Lorem.sentence,
            unit_price:Faker::Number.decimal(l_digits: 2)}]
          )
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
        # params = {
        #   "name": "value1",
        #   "description": "value2",
        #   "unit_price": 100.99,
        #   "merchant_id": merchants.first.id
        # }
        post "/api/v1/items", params: {item: {"name": "value1",
                                              "description": "value2",
                                              "unit_price": 100.99,
                                              "merchant_id": merchants.first.id}}
        expect(response).to be_successful
        created = JSON.parse(response.body, symbolize_names: true)
        expect(created).to have_key(:data)
        expect(created[:data]).to have_key(:id)
        expect(created[:data]).to have_key(:type)
        expect(created[:data]).to have_key(:attributes)
        expect(created[:data][:type]).to eq("item")
        expect(created[:data][:attributes]).to have_key(:name)
        expect(created[:data][:attributes]).to have_key(:description)
        expect(created[:data][:attributes]).to have_key(:unit_price)
        expect(created[:data][:attributes]).to have_key(:merchant_id)

      end
    end
