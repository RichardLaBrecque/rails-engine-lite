# frozen_string_literal: true

module Api
  module V1
    class MerchantItemsController < ApplicationController
      def index
        merchant = Merchant.find(params[:merchant_id])
        render json: ItemSerializer.new(Item.select('*').where('items.merchant_id = ?', params[:merchant_id]))
      end
    end
  end
end
