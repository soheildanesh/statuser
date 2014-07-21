class ItemTypeController < ApplicationController

  def destroy
      if(get_current_user.nil?)
          not get_current_user[:notice] = "log in to delete"
          redirect_to controller:'login_session', action:'new'
          return
      elsif(get_current_user['role'] != 'admin')
          not get_current_user[:notice] = "only an admin can delete"
          redirect_to controller:'login_session', action:'new'
          return
      else
          $itemType_collection.remove({:_id => BSON::ObjectId(params['id']) })
          redirect_to controller:'item_type', action:'index'
          return
      end
  end

  def show

  end

  def index

      if(params.has_key?("q"))
          searchString = ".*#{params['q']}.*"
          @itemTypes = $itemType_collection.find({'itemTypeName' => Regexp.new(searchString, "i")})
      else
          @itemTypes = $itemType_collection.find()
      end


      respond_to do |format|
          format.html
          format.json { render :json => @itemTypes.map{ |itemType| { 'name' => itemType['itemTypeName'], 'id'=> itemType['_id'].to_s } } } #convert to the {id:...,  name:... format that tokeninput.js likes}
      end
  end

  def new
  end

  def create
      
      if(get_current_user.nil?)
          not get_current_user[:notice] = "User not logged in"
          render :action => 'index'
          return
      end
      role = get_current_user['role']
      if false and not( role == 'admin' or role == 'project controller')
          not get_current_user[:error] = "User not authorized"
          redirect_to action: 'index'
          return
      end


      #check to see if the person already exists, 
      existing_itemType = ($itemType_collection.find({:itemTypeName => params["item_type"]["itemTypeName"]}).to_a)[0]

      if(!existing_itemType .nil?)
          not get_current_user[:notice] = "An item type with this name exists already"
      else    
          params["item_type"]['createdAt'] = Time.now                
          params["item_type"]['createdBy'] = get_current_user['_id']

          $itemType_collection.insert(params["item_type"])
          #ensure the insert happened
          mongodbLastError = $testDb.get_last_error({:w => 1})
          if(mongodbLastError["err"] != nil or mongodbLastError["ok"] != 1.0)
              raise "mongodb returend error after write, write might not have happened!"  
          end
      end


      @allItemTypes = $itemType_collection.find().to_a.reverse
      redirect_to controller:'item_type', action:'index'
  end
end
