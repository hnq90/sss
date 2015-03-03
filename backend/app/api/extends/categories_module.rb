# coding: UTF-8

module Extends
  class CategoriesModule < Grape::API
    format :json

    ###
    # API for Categories Resources
    ###
    resources :categories do

      ###
      # GET /api/v1/categories
      ###
      desc 'List all categories'
      get '/' do
        Category.all
      end

    end
    ###
    # End Categories Resources
    ###
    
  end
end