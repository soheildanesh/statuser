class BidController < ApplicationController
    def new
    end
    
    def create
        $bid_collection.insert(params[:bid])
        redirect_to action: 'index'        
    end
    
    def index
        if(current_user.nil?)
            flash[:notice] = "Have to be admin user for this"
            render '/login_session/new'
            return
        elsif(current_user['role'] == 'admin')
            @bids = $bid_collection.find().sort( :_id => :desc ).to_a
        end
    end 
end