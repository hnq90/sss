# coding: UTF-8

module Extends
  class UsersModule < Grape::API
    format :json

    ###
    # API for Users Resources
    ###
    resources :users do
    end
    
  end
end