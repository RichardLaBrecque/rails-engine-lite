# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApplicationController
      def find
        if !params[:name] || params[:name] == ''
          render status: 400
        else
          merchant = Merchant.select('*').where('name ilike ?', "%#{params[:name]}%").order(:name).first
          if merchant.nil?
            render json: { data: { "message": 'Could not complete your query',
                                   "errors": ['No Merchant matches found'] } }
          else
            render json: MerchantSerializer.new(merchant)
          end
        end
      end

      def find_all
        if !params[:name] && !params[:min_price] && !params[:max_price]
          render status: 400
        elsif params[:name] && params[:min_price] || params[:name] && params[:max_price]
          render json: { data: { "message": 'Could not complete your query',
                                 "errors": ['Cannot combine query types name and price'] } }
        elsif params[:name] == ''
          render status: 400
        elsif params[:name]
          @items = Item.select('*').where('name ilike ?', "%#{params[:name]}%")
          render json: ItemSerializer.new(@items)
        elsif params[:min_price] && params[:max_price]
          @items = Item.select('*').where('unit_price >= ?', params[:min_price].to_s)
                       .where('unit_price <= ?', params[:max_price].to_s)
          render json: ItemSerializer.new(@items)
        elsif params[:min_price] && !params[:max_price]
          @items = Item.select('*').where('unit_price >= ?', params[:min_price].to_s)
          render json: ItemSerializer.new(@items)
        elsif !params[:min_price] && params[:max_price]
          @items = Item.select('*').where('unit_price <= ?', params[:max_price].to_s)
          render json: ItemSerializer.new(@items)
        end
      end
      def most_items
        if !params[:quantity]
          render json: JSON.generate({error: "error"}), status: 400
        else
          number = params[:quantity]
          merchants = Merchant.top_merchants_by_items_sold(number)
          render json: ItemsSoldSerializer.new(merchants)
        end
      end

      def total_revenue
        if params[:start] == "" || params[:end] == ""
          render json: JSON.generate({error: "error"}), status: 400
        else
          total = InvoiceItem.total_revenue(params[:start], params[:end])
          render json: total
        end
      end
    end
  end

end
