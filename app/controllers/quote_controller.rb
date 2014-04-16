class QuoteController < ApplicationController
    def show
        id = params['id']
        @quote = $quote_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0] 
    end
    
    def showWoQuotes
        woid = params['id']
        @quotes = $quote_collection.find({"woId" => woid } ).to_a
        render 'index'
    end
    
    def new
        if( not params["woId"].nil?)
            woId = params["woId"]
            @wo = $wo_collection.find({ :_id => BSON::ObjectId(woId) } ).to_a[0]
        end
    end
    
    def create
        if(params['quote'].nil? )
            return nil
        end
        @quote = params['quote']
        quoteId = $quote_collection.insert(@quote)
        
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(@quote['woId']) } ).to_a[0]
        @wo["quoteId_#{quoteId}"] = quoteId
        $wo_collection.save(@wo)
        redirect_to controller: 'work_order', action: 'show', id: @wo['_id']
    end
    
    def index
         if(current_user.nil?)
             flash[:notice] = "Have to be admin user for this"
             render '/login_session/new'
             return
         elsif(current_user['role'] == 'admin')
             @quotes = $quote_collection.find().sort( :_id => :desc ).to_a
         end        
    end
    
    def updateAcceptanceStatus
        if(current_user.nil?)
            flash[:notice] = "Have to be admin user for this"
            render '/login_session/new'
            return
        elsif(current_user['role'] == 'admin')
             
            #get old quote
            quote = $quote_collection.find({:_id => BSON::ObjectId(params['id'])}).to_a[0]
             
            #equalize a new quote to the old quote (with same mongodb _id) but add the 'rejected => true' key value pair and save
            updatedQuote = Hash.new
            quote.each do |key, value|
                 updatedQuote[key] = value
            end
            updatedQuote['status'] = {:status => params['status'], createdAt: Time.now}
            
            if(params['status'] == 'accepted')
                wo = $wo_collection.find({:_id => BSON::ObjectId(quote['woId'])}).to_a[0]
                wo['acceptedQuoteId'] = quote['_id']
                $wo_collection.save(wo)
              # >>>write to the work order record 
            end
            $quote_collection.save(updatedQuote)
        end
        
        redirect_to controller: 'work_order', action: 'show', id: quote['woId'] 
    end
    
    
end