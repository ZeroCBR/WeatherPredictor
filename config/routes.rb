Rails.application.routes.draw do
  get 'welcome/index'

 



  get 'weather/prediction/:lat/:long/:period' , to: 'predict#predict_by_LatLon',  lat: /-[3][3-9]\.\d+/, long:/[1][4][0-9]\.\d+/, period: /10|30|60|120|180/

  get 'weather/prediction/:post_code/:period' , to: 'predict#predict_by_pcode', post_code: /3\d{3}/, period: /10|30|60|120|180/

  get 'weather/data/:location_id/:date', to: 'data#data_by_loc', location_id: /[A-Z].+/, date: /((0[1-9]|[1-2][0-9]|3[0-1])-(01|03|05|07|08|10|12)|((0[1-9]|[1-2][0-9]|30)-(04|06|09|11))|((0[1-9]|1[0-9]|2[0-8])-02))-\d{4}/

  get 'weather/data/:post_code/:date', to: 'data#data_by_pcode', post_code: /3\d{3}/ ,   date: /((0[1-9]|[1-2][0-9]|3[0-1])-(01|03|05|07|08|10|12)|((0[1-9]|[1-2][0-9]|30)-(04|06|09|11))|((0[1-9]|1[0-9]|2[0-8])-02))-\d{4}/
  
  get 'weather/locations' =>'data#listLocations'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
