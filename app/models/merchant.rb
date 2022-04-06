# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :invoices
  has_many :items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices
  has_many :invoice_items, through: :items
  validates_presence_of :name

  def self.top_merchants_by_revenue(number)
    joins(invoices: [:invoice_items, :transactions])
    .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    .group('merchants.id')
    .select('merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
    .order(total_revenue: :desc)
    .limit(number)
  end

  def self.top_merchants_by_items_sold(number)
    joins(invoices: [:invoice_items, :transactions])
    .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    .group('merchants.id')
    .select('merchants.*, SUM(invoice_items.quantity) AS total_items_sold')
    .order(total_items_sold: :desc)
    .limit(number)
  end

  def total_revenue
    invoices.joins(invoice_items: :transactions)
    .where(transactions: { result: "success"}, invoices: { status: 'shipped'})
    .select("invoices.*, SUM(invoice_items.unit_price * invoice_items.quantity)as revenue")
    .group(:id)
    .sum(&:revenue)
  end
end
