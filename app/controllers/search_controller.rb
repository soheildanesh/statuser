class SearchController < ApplicationController
    
    def index
        if(current_user.nil? or current_user['role'] != 'admin')
            flash[:notice] = "LOGin, as admin, to see the LOG!"
            render '/login_session/new'
            return
        end
    end
    
    def create
        if(current_user.nil? or current_user['role'] != 'admin')
            flash[:notice] = "LOGin, as admin, to see the LOG!"
            render '/login_session/new'
            return
        end
        params['search']['person'].downcase!
        searchHash = Hash.new
        params['search'].each do |key, value|
            if(not (value.nil? or value.empty?) )

                if(key=='changeRequestPrice')
                    if(params['priceRange'] == '>')
                        value = {"$gt" => value}
                    elsif(params['priceRange'] == '<')
                        value = {"$lt" => value}
                    end
                end
                
                searchHash[key]=value 
            end
        end
        
#        searchHash['changeRequestPrice'] = searchHash['changeRequestPrice'].to_i
        puts("searchHash = #{searchHash}")
        @log_entries = $log_entry_collection.find(searchHash).sort( :_id => :desc ).to_a
        
        @persons = $person_collection.find(email: params['search']['person']).sort( :_id => :desc ).to_a
        
        @sites = $site_collection.find(siteId:  params['search']['siteId']).sort( :_id => :desc ).to_a
        render 'index'
    end
    
end