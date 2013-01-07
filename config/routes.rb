FriendWatcherRails::Application.routes.draw do
  post "facebook/rtu"
  get "facebook/rtu"

  resources :users, only: [ :create, :show ] do
    get :verify_token, :on => :member
    get :force_refresh, :on => :member
    get :test_push, :on => :member
    resources :devices, only: [:create, :delete, :update]
  end


end
#== Route Map
# Generated on 06 Jan 2013 09:16
#
#  verify_token_user GET  /users/:id/verify_token(.:format)     users#verify_token
# force_refresh_user GET  /users/:id/force_refresh(.:format)    users#force_refresh
#     test_push_user GET  /users/:id/test_push(.:format)        users#test_push
#       user_devices POST /users/:user_id/devices(.:format)     devices#create
#        user_device PUT  /users/:user_id/devices/:id(.:format) devices#update
#              users POST /users(.:format)                      users#create
#               user GET  /users/:id(.:format)                  users#show
