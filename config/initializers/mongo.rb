require 'mongo'
include Mongo
@client = MongoClient.new('0.0.0.0', 27017) 
#todo think of creating different db's to minimize write lock waiting
$testDb = @client['test']
$log_entry_collection = $testDb['log_entry_collection']
$person_collection = $testDb['person_collection']
$site_collection = $testDb['site_collection']