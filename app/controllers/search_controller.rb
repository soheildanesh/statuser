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
        
        @persons = $person_collection.find(email: params['search']['person']).sort( :_id => :desc ).to_a
        
        @sites = $site_collection.find(siteId:  params['search']['siteId']).sort( :_id => :desc ).to_a
        render 'index'
    end
    
end