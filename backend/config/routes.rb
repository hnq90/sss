Rails.application.routes.draw do
  root 'admin#index'

  #Mount Grape app
  mount API::SSS => '/'
end
