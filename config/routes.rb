Statuser::Application.routes.draw do
  
    resources :feedback
    
    resources :log_entry do
        member do
            get :add_cr_to_activity_report
            get :show_cr_written_proof
            get :show_crew_change_form
            get :show_change_request_form
            get :new_activity_report
            get :show_full_activity_report
            get :new_change_request
        end
    end
    
    resources :person do
        member do
            patch :changeMode
        end
    end

    resources :login_session
    resources :site do
        member do
            get :show_options
            get :siteTasks
        end
    end
    

    resources :search do
        member do
            get :quick_search
        end
    end
    
    resources :bid
    
    resources :quote do
        member do
            post :updateAcceptanceStatus
            get :showWoQuotes
        end
    end
    
    resources :project do
        member do
            get :newSearch
            get :search
            patch :updateMilestone
            patch :uploadMilestoneFile
            get :newSprintBid
            get :indexSprintOrders
            get :newSprintOrder
            get :generateSprintOrderLines
            patch :createSprintOrder
            get :showSprintOrder
            patch :addPoToSprintOrder
            get :milestone_files
            get :showMilestones
            get :editSprintOrder
            patch :updateOrder
        end
    end
    
    resources :cpo
    
    resources :work_order do
        member do
            post :addCpo
            get :showCpo
            get :newAuthorizationRequest
            get :newChangeRequest
            post :updateGrantStatus
            get :showGrant
            get :newPreApprovalRequest
            post :addGrcr
            post :addWorkComplete
            get :showGrcr
            post :updateWoAcceptance
            get :showWoAcceptance
            get :showWorkComplete
            get :newSearch
            get :search
        end
    end
    
    resources :change_request do
        member do
            get :newPreApprovalRequest
            get :newAuthorizationRequest
            post :update3sPmGrant
            get :showPm3sGrant
        end
    end
    
    resources :list
    
    resources :program
    
    resources :customer
    
    resources :project_type
    
    resources :item_type
    
    resources :todolist
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'login_session#new'

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
