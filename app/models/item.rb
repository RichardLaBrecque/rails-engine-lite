# frozen_string_literal: true
class Merchant < ApplicationRecord
  has_many :items
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.checkthenrek
    invoices = Invoice.all
    invoices.each do |invoice|
      if invoice.items == nil
        invoice.destroy
      end
    end
  end
end
