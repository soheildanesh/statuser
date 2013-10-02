#todo encypt passwords
require 'mongo'
include Mongo

#on tasks and how to call them : http://railsguides.net/2012/03/14/how-to-generate-rake-task/
namespace :setup_admin_users do
    
    @client = MongoClient.new('0.0.0.0', 27017) 
    #todo think of creating different db's to minimize write lock waiting
    $testDb = @client['test']
    $person_collection = $testDb['person_collection']

    desc "TODO"
    task :add_admins => :environment do
        admins = Array.new
        admins << boss = {email: "S_Danesh@3Snetwork.com".downcase!, name: "Saeid Danesh", role: "admin", password:"falaamak"}
        admins << sina = {email: "Sina.Danesh@3Snetwork.com".downcase!, name: "Sina Danesh", role: "admin", password:"falaamak"}
        admins << soheil = {email: "Soheil.Danesh@3Snetwork.com".downcase!, name: "Soheil Danesh", role: "admin", password:"falaamak"}
        
        admins << birju = {email: "Birju.Shah@3Snetwork.com".downcase!, name: "Birju Shah", role: "admin", password:"3spmt00l"}
        
        #produce an incremented id
        last_entry = $person_collection.find().sort( :_id => :desc ).to_a
        if(last_entry[0].nil? or last_entry.empty?)
            id = 1
        else
            id = last_entry[0]['_id'] + 1
        end
        
        for admin in admins
            admin['_id'] = id
            id = id+1

            $person_collection.insert(admin)
        end
    end
  
  
end