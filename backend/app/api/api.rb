# coding: UTF-8
require 'grape'

module API

  ###
  # Format object when success
  ###
  module SuccessFormatter
    def self.call object, env
      tmp_hash = Hash.new
      if object.is_a?(ActiveRecord::Base)
        tmp_hash = { object.class.table_name.singularize => object  }
      elsif object.is_a?(ActiveRecord::Relation)
        tmp_hash = { object.table_name => object }
      elsif object.is_a?(String)
        tmp_hash = ActiveSupport::JSON.decode(object)
      else
        tmp_hash = object
      end
      JSON.pretty_generate(JSON.parse({ success: true, data: tmp_hash }.to_json))
    end
  end

  ###
  # Format Error Response
  # error!(message, http status) -> error!('Unauthorize', 404)
  ###
  module ErrorFormatter
    def self.call message, backtrace, options, env
      JSON.pretty_generate(JSON.parse({ success: false, message: message }.to_json))
    end
  end

  class SSS < Grape::API
    version 'v1', using: :path
    prefix 'api'
    format :json

    # Response Formatter
    formatter :json, SuccessFormatter
    error_formatter :json, ErrorFormatter

    ###
    # Global rescue when record not found (catch error)
    ###
    rescue_from ActiveRecord::RecordNotFound do |e|
      error_response(success: false, message: e.message, status: 404)
    end

    ###
    # Global rescue when other exception
    ###
    rescue_from :all do |e|
      error_response(success: false, message: e.message, status: 500)
    end

    ###
    # Helpers
    ##
    helpers do
      # Check header for more security
      def check_header!
        error!('Unauthorized Access', 401) unless (headers['X-SSS-Client-Version'] == 'v1.0' && headers['X-SSS-Client-Type'] == 'SSS')
      end

      # Check authenticate
      def authenticate!
        error!('Unauthorized. You need to login', 401) unless current_user
      end

      # Find current logged user
      def current_user
        u = User.where(uid: params[:uid], token: params[:token]).first
        u ? @current_user = u : false
      end

      # Strong params
      def permitted_params
        @permitted_params ||= declared(params, include_missing: false)
      end
    end

    mount Extends::UsersModule
    mount Extends::CategoriesModule

  end
end
