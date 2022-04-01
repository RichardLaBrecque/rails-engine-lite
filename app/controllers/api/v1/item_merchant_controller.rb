# frozen_string_literal: true

module Api
  module V1
    class ItemMerchantController < ApplicationController
      def index
        item = Item.find(params[:item_id])
        render json: MerchantSerializer.new(item.merchant)
      end
    end
  end
end
