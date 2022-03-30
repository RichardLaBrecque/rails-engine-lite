require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'
    expect(response).to be_successful
    merchants = JSON.parse(response.body, symbolize_names: true)
    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'can get a single merchant' do
    merchants = create_list(:merchant, 3)
    get "/api/v1/merchants/#{merchants.first.id}"
    expect(response).to be_successful
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant).to have_key(:data)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merchants.first.name)
  end

  it 'can find a merchant by partial name' do
      merchant1 = Merchant.create!(name: "First")
      merchant2 = Merchant.create!(name: "Second")
      merchant3 = Merchant.create!(name: "THIRD")

      get "/api/v1/merchants/find", params: {"name": "ir"}
      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(merchant).to have_key(:data)
      expect(merchant[:data]).to have_key(:type)
      expect(merchant[:data]).to have_key(:attributes)
      expect(merchant[:data][:type]).to eq("merchant")
      expect(merchant[:data][:attributes][:name]).to eq("First")
  end
  it 'can return an error for no matches' do
      merchant1 = Merchant.create!(name: "First")
      merchant2 = Merchant.create!(name: "Second")
      merchant3 = Merchant.create!(name: "THIRD")

      get "/api/v1/merchants/find", params: {"name": "wq"}
      merchant = JSON.parse(response.body, symbolize_names: true)
      expect(merchant).to have_key(:data)
      expect(merchant[:data]).to have_key(:message)
      expect(merchant[:data]).to have_key(:errors)
      expect(merchant[:data][:message]).to eq("Could not complete your query")
      expect(merchant[:data][:errors]).to eq(["No Merchant matches found"])
  end
end
