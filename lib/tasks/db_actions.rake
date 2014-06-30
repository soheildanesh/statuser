#todo encypt passwords
require 'mongo'
include Mongo

#on tasks and how to call them : http://railsguides.net/2012/03/14/how-to-generate-rake-task/
#rake my_namespace:my_task1
namespace :db_actions do
    
    
    #one time tasks###############################
    #for some mysterious reason projects added by hortencia have Modification for projType instead of its bson ID
    task :replaceProjTypeNameWithIDInProjects => :environment do
        
        projects = $project_collection.find()
        
        for project in projects
            #see if project['projType'] is a bson id (as it should be) if not change it into one
            projectType = $projectType_collection.find_one({'projectTypeName' => Regexp.new(project['projType'], "i")})
            if not projectType.nil?
               # then the project's projectType field indeeds holds the name not the id of the project tyoe
               project['projType'] = projectType['_id'].to_s
               $project_collection.save project
            end
        end
    
    end
    
    
    task :projectTypeId_to_s => :environment do
        projects = $project_collection.find()
        
        for project in projects
           project['projType'] =  project['projType'].to_s
        end

    end
    
    #one time tasks###############################
    
    @client = MongoClient.new('0.0.0.0', 27017) 
    #todo think of creating different db's to minimize write lock waiting
    $testDb = @client['test']
    $log_entry_collection = $testDb['log_entry_collection']
    $person_collection = $testDb['person_collection']
    $site_collection = $testDb['site_collection']

    desc "TODO"
    task :add_admins => :environment do
        admins = Array.new
        admins << boss = {email: "S_Danesh@3Snetwork.com".downcase!, name: "Saeid Danesh", role: "admin", password: rand(999999).to_s}
        
        admins << sina = {email: "Sina.Danesh@3Snetwork.com".downcase!, name: "Sina Danesh", role: "admin", password:rand(999999).to_s}
        
        admins << soheil = {email: "Soheil.Danesh@3Snetwork.com".downcase!, name: "Soheil Danesh", role: "admin", password:rand(999999).to_s}
        
        admins <<  {email: "Birju.Shah@3Snetwork.com".downcase!, name: "Birju Shah", role: "admin", password:rand(999999).to_s}
        
        admins << {email: "tim.burton@3Snetwork.com".downcase!, name: "Tim Burton", role: "admin", password:rand(999999).to_s}
        
        admins << {email: "roger.smith@3Snetwork.com".downcase!, name: "Roger Smith", role: "admin", password:rand(999999).to_s}
        
        admins <<  {email: "shahrooz.taebi@3Snetwork.com".downcase!, name: "Shahrooz Taebi", role: "admin", password:rand(999999).to_s}
        
        admins <<  {email: "bjorn.burlin@3Snetwork.com".downcase!, name: "Bjorn Burlin", role: "admin", password:rand(999999).to_s}
        

        
        #produce an incremented id
        last_entry = $person_collection.find().sort( :_id => :desc ).to_a
        if(last_entry[0].nil? or last_entry.empty?)
            id = 1
        else
            id = last_entry[0]['_id'] + 1
        end
        
        for admin in admins
            existing_person = $person_collection.find({"email" => admin[:email] }).to_a[0]
            if(existing_person.nil?)
                admin['_id'] = id
                id = id+1
                $person_collection.insert(admin)
            end
        end
    end
    
    task :delete_everything => :environment do
        $log_entry_collection.remove()
        $person_collection.remove()
        $site_collection.remove()
    end
end