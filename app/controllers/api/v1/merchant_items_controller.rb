class Api::V1::MerchantItemsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: ItemSerializer.new(Item.select("*").where("items.merchant_id = ?", params[:merchant_id]))
  end
end
