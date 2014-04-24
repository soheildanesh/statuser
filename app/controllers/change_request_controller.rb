class ChangeRequestController < ApplicationController
   def create
       @cr = Hash.new()
       @cr = params['change_request']
       @cr['createdAt'] = Time.now
       @cr['createdBy'] = $current_user['_id']
       
       @cr['parent__wo__id'] = params['woId']

       @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['woId']) }).to_a[0]
       crid = $cr_collection.insert(@cr)
       @wo["child__cr__#{crid}"] = crid
       $wo_collection.save(@wo)
       
       redirect_to action: 'show', id: crid
   end 
   
   def show
       @cr = $cr_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
       
       @childWos = Array.new
       @cr.each do |key, value|
           if(key.include? 'childWo_id') 
               wo = $wo_collection.find({ :_id => BSON::ObjectId(value.to_s) }).to_a[0]
               @childWos << wo
           end
       end
       
       if not @childWos.nil? 
           @childWos.sort!{|x,y| y['createdAt'] <=> x['createdAt']} 
       end
   end
   
   def showPm3sGrant
       @cr = $cr_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
   end
   
   def update3sPmGrant
       cr = $cr_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
       grant = params['change_request']['pm3sGrant']

       grant['created_at'] = Time.now
       grant['created_by'] = current_user['_id']

       cr['pm3sGrant'] = grant

       $cr_collection.save(cr)

       redirect_to action: 'show', id: cr['_id'].to_s
   end
   
   
   
   def newPreApprovalRequest
        if(params['type'] == 'crReport')
            redirect_to controller: 'work_order', action: 'new', crId:params['crid'], type: 'CR Report > Pre-Approval Request'
        elsif(params['type'] == 'crInquiry')
            redirect_to controller: 'work_order', action: 'new', crId:params['crid'], type: 'CR Inquiry > Pre-Approval Request'
        end
   end
   
   def newAuthorizationRequest
       if(params['type'] == 'crReport')
           redirect_to controller: 'work_order', action: 'new', crId:params['crid'], type: 'CR Report > Authorization Request'
       elsif(params['type'] == 'crInquiry')
           redirect_to controller: 'work_order', action: 'new', crId:params['crid'], type: 'CR Inquiry > Authorization Request'
       end
   end
end