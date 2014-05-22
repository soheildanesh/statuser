class ProjectController < ApplicationController

    #sprint
    def createOrUpdateSprintOrder
        
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        #save the bid file and replace it with the address on file system in params
        bidFile = nil
        
        if not @project.has_key? 'orders'
            @project['orders'] = Hash.new
            ordCount = 0
        else
            ordCount = @project['orders'].length
        end
        ordCount = ordCount+1 #so we start with 1


        if(params['order'].has_key? 'bidFile' )
            bidFile = params['order']['bidFile']
            
        
        
            FileUtils.cd(Rails.root)
            FileUtils.cd('public')
            if(not FileUtils.pwd().split("/").last == "uploads")
                FileUtils.cd('uploads')
            end
        
            if not Dir.exists? ("#{@project['projId3s']}__#{@project['_id'].to_s}")
                FileUtils.mkdir("#{@project['projId3s']}__#{@project['_id'].to_s}")
            end
            FileUtils.cd("#{@project['projId3s']}__#{@project['_id'].to_s}")                
        
            if not Dir.exists? ("orders")
                FileUtils.mkdir("orders")
            end
            FileUtils.cd("orders")
            
            if not Dir.exists? (ordCount.to_s)
                FileUtils.mkdir(ordCount.to_s)
            end
            FileUtils.cd(ordCount.to_s)
        
            File.open( bidFile.original_filename, 'wb') do |file|
                file.write(bidFile.read)
            end 

            params['order']['bidFile'] = bidFile.original_filename
        end
        
        @project['orders']["#{ordCount}"] = params['order']
        
        $project_collection.save(@project)
        redirect_to controller:'project', action: 'indexSprintOrders', id: @project['_id']    
    end
    
    def showSprintOrder
        
        @orderId3sn = params['orderId3sn']
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
    end
    
    def generateSprintOrderLines
        @numlines = params['numLines']
        @orderId3sn = params['orderId3sn']
        
        respond_to do |format|
            format.html
            format.js
        end
    end
    
    def indexSprintOrders
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
    end
    
    def newSprintOrder
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        @orderCount = 1
        if( @project.has_key? 'orders')
            puts("project orders = #{@project['orders']}")
            @orderCount = @project['orders'].length + 1
        end
    end
    
    
    #sprint
    def updateMilestone
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        #projMilestoneUpdate = params['project']
        if(not @project.has_key? 'milestones')
            @project['milestones'] = Hash.new
        end
        
        #note duplicate keys get overwritten and set to what's in projMilestoneUpdate
        #how this works
        #exsiting:
        #milestones => {m1 => {proerty1 => value1} m2 => ...}
        #incoming: milestones => {m1 = {property2 => value2} ... }
        #outcome: milestones => {m1 => {prop1 => value1, prop2 => value2}, ...}
        # milestone "m1" has been updated
        
        puts("@project['milestones'] = #{@project['milestones']}")
        puts("params['project']['milestones'] = #{params['project']['milestones']}")
        
        byebug
        @project['milestones'] = @project['milestones'].merge (params['project']['milestones']) do 
            |key, v1, v2|
            puts"we hea with key = #{key}, v1 = #{v1}, v2 = #{v2}"
            puts("v1.class = #{v1.class}")
            puts("v2.class = #{v2.class}")
            if(v1.is_a? Hash and v2.is_a? Hash)
                v1.merge v2
            else
                v2
            end
        end
        
        $project_collection.save(@project)
        puts("project = #{@project}")
        redirect_to controller:'project', action: 'show', id: @project['_id']
    end
    
    def uploadMilestoneFile 
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        if(not @project.has_key? 'milestones')
            @project['milestones'] = Hash.new
        end
        
        params['project']['milestones'].each do |milestone, uploadedFile|
            if(not  @project['milestones'].has_key? milestone)
                @project['milestones'][milestone] = Hash.new
            end
            puts("pwd = #{FileUtils.pwd()}")
            FileUtils.cd(Rails.root)
            FileUtils.cd('public')
            if(not FileUtils.pwd().split("/").last == "uploads")
                FileUtils.cd('uploads')
            end
            
            if Dir.exists? ("#{@project['projId3s']}__#{@project['_id'].to_s}")
                FileUtils.cd("#{@project['projId3s']}__#{@project['_id'].to_s}")                
            else
                FileUtils.mkdir("#{@project['projId3s']}__#{@project['_id'].to_s}")
                FileUtils.cd("#{@project['projId3s']}__#{@project['_id'].to_s}")                
            end
            
            File.open( uploadedFile.original_filename, 'wb') do |file|
                file.write(uploadedFile.read)
            end
            
            if(not @project['milestones'][milestone].has_key? "files")
                @project['milestones'][milestone]["files"] = Hash.new
            end
            numExistingMsFiles = @project['milestones'][milestone]["files"].length
            @project['milestones'][milestone]["files"][(numExistingMsFiles+1).to_s] = {fileName: uploadedFile.original_filename , uploadTime: Time.now, uploadedBy: current_user['_id'] }
            
        end
        flash[:notice] = "File uploaded"
        $project_collection.save(@project)
        
        redirect_to action: 'show'
    end
    
    def new
        @projId3s = genSamllUniqId $project_collection, 'projId3s'
    end
    
    def show
        id = params['id']
        @project = $project_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0]
        
        @projectCustomerName = $customer_collection.find_one(:_id => BSON::ObjectId(@project['customerId']))['customerName']
        
        if( @projectCustomerName == "ericsson")
            @wos = Array.new
            @project.each do |key, value|
                if(key.include? 'wo_id')
                    wo = $wo_collection.find(:_id => value).to_a[0]
                    if(not wo.nil?)
                        @wos << wo
                    end   
                end
            end
            @wos.sort!{|x,y| y['createdAt'] <=> x['createdAt']}
        end
        
        if( @projectCustomerName  == "sprint")

            #get the milestone dependecies list for this project. Each array in the array represents a depndecy. The first memebr is the milestone and the others are the ones it depends on ie its prereqs
 #[ ["m1"], ["m2", "m1"], ["m3", "m2"]]
 
            @milestoneDependecies =  [
            ["Bid Invitation Received"],
            ["Pre-Bid Conference Complete", "Bid Invitation Received"],
            ["Bid Walk Complete", "Pre-Bid Conference Complete"],
            ["Bid Complete", "Bid Walk Complete"],
            ["Bid Review Complete", "Bid Complete"],
            ["SAP Submitted", "Bid Review Complete"],
            ["SAP Approved", "SAP Submitted"],
            ["Initial Bid POR Submitted", "SAP Approved"],
            ["Initial Bid PO Received", "Initial Bid POR Submitted"],
            ["NTP Received", "Initial Bid PO Received"],
            ["Pre-Construction Visit Complete", "Initial Bid PO Received", "NTP Received"],
            ["Cell Site Verification Complete", "Pre-Construction Visit Complete"],
            ["Material Order Submitted", "Cell Site Verification Complete"],
            ["Material Received", "Material Order Submitted"],
            ["Equipment Pickup Complete", "Initial Bid PO Received", "NTP Received"],

            ["Equipment Inventory Complete", "Equipment Pickup Complete"],
            ["Construction Start", "Equipment Inventory Complete", "Material Received"],

            ["Change Request Submitted", "Construction Start"],
            ["Change Request Approved", "Change Request Submitted"],
            ["Change Request PO Received", "Change Request Approved"],
            ["Ground Level Construction Complete", "Construction Start"],
            ["Tower Level Construction Complete" , "Construction Start"],
            ["Commissioning & Integration Schedule Complete", "Ground Level Construction Complete", "Tower Level Construction Complete"],
            ["Commissioning & Integration Complete", "Commissioning & Integration Schedule Complete"],
            ["Sprint-Provided Punchlist Received", "Ground Level Construction Complete", "Tower Level Construction Complete"],


            ["Punchlist Clean-up Complete", "Sprint-Provided Punchlist Received"],

            ["Return of Unused Equipment Complete", "Ground Level Construction Complete", "Tower Level Construction Complete"],


            ["Construction Documents Complete", "Punchlist Clean-up Complete", "Return of Unused Equipment Complete"],


            ["Construction Documents Submitted", "Construction Documents Complete"],
            ["Construction & Final Acceptance Checklist Complete", "Punchlist Clean-up Complete", "Return of Unused Equipment Complete"],


            ["Construction Complete", "Construction Documents Submitted", "Construction & Final Acceptance Checklist Complete"],


            ["Final Acceptance Documents Complete", "Construction Complete"],
            ["Acceptance Request Submitted", "Final Acceptance Documents Complete"],
            ["Final Acceptance", "Acceptance Request Submitted"]]
            
        end
         
        render "show_#{@projectCustomerName}"
         
    end
    
    def destroy
        tobeDeleted = $project_collection.find({_id: params['id'].to_i}).to_a[0]
        if(current_user['role'] == 'admin' or tobeDeleted['createdBy'] == current_user['_id'])
            $project_collection.remove({_id: BSON::ObjectId(params['id'])})
            redirect_to controller:'project', action:'index'
            return
        else
            flash[:error] = "you dont have permission to delete this entry, contact and admin"
            redirect_to controller:'project', action:'index'
            return
        end
    end
    
    def create
        if( params['project'].nil? )
            return nil
        end
        
        #TODO check admin status so not just any one can create new proj
        
        #create new project and add quoteId to it
        @project = Hash.new()
        @project = params['project']
        @project['createdAt'] = Time.now
        @project['createdBy'] = $current_user['_id']
        
        
        
        okToCreate = true

        #make sure all fields have been entered before creating object
        missingKey = ""
        @project.each do |key, value|
          if value.nil?
              okToCreate = false
              missingKey = key
          elsif value.to_s.empty?
              okToCreate = false
              missingKey = key
          end

        end

        if(not okToCreate)
            flash[:error] = "Project could not be created because not all ( #{missingKey}) fields required for a new project were entered."
        end

        if(okToCreate)
          #make sure the project name is unique
          project = $project_collection.find({'projName' => @project['projName'] } ).to_a[0]
          if(project.nil?)

          elsif(project.empty?)

          else
              okToCreate = false
              flash[:error] = "Poject could not be created becuse project's name already exists in the databse, please enter a unique project name"
          end
        end

        if(okToCreate)
          flash[:error] = ""
        end

        if(okToCreate)
          #@project['3sId'] = id3s

          projectId = $project_collection.insert(@project)

          redirect_to action: 'index'
        else
          redirect_to action: 'new'
        end
    end
    
    def edit
         @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
    end
    
    def update
        
         if(not current_user.nil?)
             if(not current_user['role'] == 'admin')
                 flash[:notice] = "Have to be admin user for this"
                 render '/login_session/new'
                 return
             end
        else
            flash[:notice] = "Have to be logged in for this"
            render '/login_session/new'
            return
        end
        
        
        
        #find and remove record to be updated
        record = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
        
        params['project'].each do |key, value| 
            if key == '_id'
                next
            end
            record[key] = value
        end
        
        $project_collection.save(record)
   
        redirect_to controller: "project", action: "show", id: record['_id']
        
     end
    
    def index
        if(current_user.nil?)
             flash[:notice] = "Have to be admin user for this"
             render '/login_session/new'
             return
         elsif(current_user['role'] == 'admin')
             if(current_user['customerMode']['customerId'] == "All Customers")
                 @projects = $project_collection.find().sort( :_id => :desc ).to_a
                 @customerInMode = "All Customers"
             else
                 @projects = $project_collection.find({"customerId" => current_user['customerMode']['customerId'] }).sort( :_id => :desc ).to_a
                 @customerInMode = $customer_collection.find_one( {:_id => BSON::ObjectId(current_user['customerMode']['customerId']) } )['customerName']
             end
         end
         
         render "index"
    end
    
    def newSearch
        
    end
    
    def search
        searchHash = Hash.new
        
        params['project'].each do |key,value|
            if(value.nil? or value.empty?)
                next
            end
            searchHash[key] = value
        end
        
        @projects = $project_collection.find(searchHash).sort( :_id => :desc ).to_a
        render 'index'
    end
end