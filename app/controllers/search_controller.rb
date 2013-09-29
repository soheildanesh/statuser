class SearchController < ApplicationController
    
    def index
#        redirect_to :controller => 'log_entry', :action => 'index'
    end
    
    def create
        searchHash = Hash.new
        params['search'].each do |key, value|
            if(not (value.nil? or value.empty?) )
               searchHash[key]=value 
            end
        end
        
        puts("searchHash = #{searchHash}")
        @log_entries = $log_entry_collection.find(searchHash).sort( :_id => :desc ).to_a
        render 'index'
    end
    
    
    
    def quick_search
        
        @query = params[:search][:query].downcase
        searchBy = params[:searchByAttribute] #the attribute to search by
        searchString = ".*#{@query}.*"
        @log_entries = $log_entry_collection.find({ searchBy => Regexp.new(searchString)} )
        render 'index'
    end
    
end