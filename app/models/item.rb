# frozen_string_literal: true
class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant
  enum status: {"Disabled" => 0, "Enabled" => 1}
  validates_presence_of :name
  validates_presence_of :description
  validates_presence_of :unit_price

   after_destroy do
     #this is close, but i think its a nested select(count)
     # wip = Invoice.left_joins(:items).group(:id).order(:id).count("items.id")
     # binding.pry
     invoices = Invoice.all
        invoices.each do |invoice|
          unless invoice.items.any?
            invoice.destroy
          end
        end
   end
end
