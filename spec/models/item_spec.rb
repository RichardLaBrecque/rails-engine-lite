require 'rails_helper'

RSpec.describe Item, type: :model do

  describe "relationships" do
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should belong_to(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
  end

  it 'deletes an invoice if it was the last item' do
      merchant_1 = Merchant.create!(name: "Staples")
      item_1 = merchant_1.items.create!(name: "stapler", description: "Staples papers together", unit_price: 13)
      item_2 = merchant_1.items.create!(name: "different stapler", description: "Staples papers together", unit_price: 13)
      customer_1 = Customer.create!(first_name: "Person 1", last_name: "Mcperson 1")
      invoice_1 = customer_1.invoices.create!(status: "completed", merchant_id: "#{merchant_1.id}")
      invoice_item_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_1.id, quantity: 1, unit_price: 13)
      invoice_item_2 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: item_2.id, quantity: 2, unit_price: 29)
      expect(invoice_1.items).to eq([item_1,item_2])
      item_1.destroy
      id = invoice_1.id
      invoice_1.reload
      expect(invoice_1.items).to eq([item_2])
      item_2.destroy
      expect{Invoice.find(id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
