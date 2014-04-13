class CpoController < ApplicationController
    
    def show
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        @cpo = @wo['cpo']
    end
    
end