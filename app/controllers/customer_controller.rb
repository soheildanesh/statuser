class CustomerController < ApplicationController
  
    def destroy
        role = current_user['role']
        if not( role == 'admin' )
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        if(current_user.nil?)
            flash[:notice] = "only an admin can delete"
            redirect_to controller:'login_session', action:'new'
            return
        elsif(current_user['role'] != 'admin')
            flash[:notice] = "only an admin can delete"
            redirect_to controller:'login_session', action:'new'
            return
        else
            projects = $project_collection.find("customerId" => BSON::ObjectId(params['id'])).to_a
            if(projects.empty?)
                $customer_collection.remove({:_id => BSON::ObjectId(params['id']) })
            else
                
            end
            redirect_to controller:'customer', action:'index'
            return
        end
    end
    
    def show
        

    end
  
    def index

        if(params.has_key?("q"))
            searchString = ".*#{params['q']}.*"
            @customers = $customer_collection.find({'customerName' => Regexp.new(searchString, "i")})
        else
            @customers = $customer_collection.find()
        end
            
        
        respond_to do |format|
            format.html
            format.json { render :json => @customers.map{ |customer| { 'name' => customer['customerName'], 'id'=> customer['_id'].to_s } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
        end
    end
  
    def new
    end
  
    def create
        
        if(current_user.nil?)
            flash[:notice] = "User not logged in"
            render :controller => 'customer', :action => 'index'
            return
        end
        role = current_user['role']
        if not( role == 'admin' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
            
        #check to see if the person already exists, 
        existing_customer = ($customer_collection.find({:customerName => params[:customer][:customerName]}).to_a)[0]

        if(!existing_customer.nil?)
            flash[:notice] = "A customer with this name exists already"
        else    
            params[:customer]['createdAt'] = Time.now                
            params[:customer]['createdBy'] = current_user['_id']
            
            $customer_collection.insert(params[:customer])
            #ensure the insert happened
            mongodbLastError = $testDb.get_last_error({:w => 1})
            if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
                raise "mongodb returend error after write, write might not have happened!"  
            end
        end
          
        @allCustomers = $customer_collection.find().to_a.reverse
        redirect_to controller:'customer', action:'index'
    end
end
