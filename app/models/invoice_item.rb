class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  has_one :merchant, through: :item
  has_many :transactions, through: :invoice
  validates_presence_of :quantity
  validates_presence_of :unit_price

  def self.total_revenue(startdate, enddate)
    joins(invoice: :transactions)
    .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    .where("invoices.created_at >= ?", startdate )
    .where("invoices.created_at <= ?", enddate)
    .group(:id)
    .select("SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue")
    .order(total_revenue: :desc)
    .sum(&:total_revenue)
    # joins(invoices: [:invoice_items, :transactions])
    # .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    # .group('merchants.id')
    # .select('merchants.*, SUM(invoice_items.quantity) AS total_items_sold')
    # .order(total_items_sold: :desc)
    # .limit(number)
  end
end
