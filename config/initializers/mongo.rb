require 'mongo'
include Mongo
@client = MongoClient.new('0.0.0.0', 27017) 
#todo think of creating different db's to minimize write lock waiting
$testDb = @client['test']
$log_entry_collection = $testDb['log_entry_collection']
$person_collection = $testDb['person_collection']
$site_collection = $testDb['site_collection']

$bid_collection = $testDb['bid_collection']
$quote_collection = $testDb['quote_collection']
$project_collection = $testDb['project_collection']
$wo_collection = $testDb['work_order_collection']
$cr_collection = $testDb['change_request_collection']
$program_collection = $testDb['program_collection']
$customer_collection = $testDb['customer_collection']
$projectType_collection = $testDb['projectType_collection']
$itemType_collection = $testDb['itemType_collection']
$feedback_collection = $testDb['feedback_collection']