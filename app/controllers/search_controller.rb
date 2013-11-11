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
        
        notesSearchString = ".*#{params['search']['notes']}.*"
        puts("***")
        puts(notesSearchString)
        @log_entries_notes = $log_entry_collection.find({notes: Regexp.new(notesSearchString) }).to_a
        @persons_notes = $person_collection.find({notes: Regexp.new(notesSearchString)}).to_a
        @sites_notes = $site_collection.find({notes: Regexp.new(notesSearchString)}).to_a
        
        params['search']['notes'] = ""
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
        
        @log_entries = $log_entry_collection.find(searchHash).sort( :_id => :desc ).to_a
        
        
        @persons = $person_collection.find(email: params['search']['person']).sort( :_id => :desc ).to_a
        
        searchString = ".*#{params['search']['person']}.*"
        @crews = $site_collection.find({'crew' => Regexp.new(searchString)})
        
        @sites = $site_collection.find(siteId:  params['search']['siteId']).sort( :_id => :desc ).to_a
        
        
        
        if(@log_entries.empty? and @persons.empty? and @sites.empty?)
            @noResultsToShow = true
        else
            @noResultsToShow = false
        end
        
        render 'index'
    end
    
end