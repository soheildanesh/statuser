class ProjectController < ApplicationController
    
    before_action :clearGon
     
    #clear js variable gon, see gon gem 
    def clearGon
        gon.clear()
    end


    #sprint
    def milestone_files
        @milestone = params['milestone']
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        puts("@project = #{@project} @milestone = #{@milestone}")
        #@milestone = @project['']
    end
    
    def createSprintOrder

        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        if(not params.has_key? 'order')
            flash[:error] = "Submitted form was empty!"
            redirect_to controller: 'project', action: 'newSprintOrder', id: @project['_id']
            return 
        end
        
        if(not params['order'].has_key? 'bid')
            flash[:error] = "Please enter the bid lines."
            redirect_to controller: 'project', action: 'newSprintOrder', id: @project['_id']
            return 
        end
        
        if(not params['order'].has_key? 'bidFile')
            flash[:error] = "Please enter the bid file."
            redirect_to controller: 'project', action: 'newSprintOrder', id: @project['_id']
            return 
        end
        
        
        if(not params['order']['bid'].has_key? 'lines')
            flash[:error] = "Please enter the bid lines!"
            redirect_to controller: 'project', action: 'newSprintOrder', id: @project['_id']
            return 
        end
        
        
            
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
        
        params['order']['createdAt'] = Time.now
        params['order']['createdBy'] = current_user['_id']
        
        
        @project['orders']["#{ordCount}"] = params['order']
        
        $project_collection.save(@project)
        redirect_to controller:'project', action: 'indexSprintOrders', id: @project['_id']    
    end
    
    def showSprintOrder
        
        @orderId3sn = params['orderId3sn']
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        #set in addPoToSprintOrder if po has non matching line with bid
        @nonMatchLine = nil 
        @poNotMatchingBid = nil
        ####
        
    end
    
    def generateSprintOrderLines
        @numlines = params['numLines']
        @orderId3sn = params['orderId3sn']
        @prefillBidOrPo = nil
        @bidOrPo = params['id']
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
    
    def addPoToSprintOrder
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        @orderId3sn = params['orderId3sn']
        @po = params['order']['po']
        puts("@project[orders][#{@orderId3sn}] = #{@project}['orders'][#{@orderId3sn}]")
        if @project["orders"]["#{@orderId3sn}"].has_key? 'bid'
            @bid = @project["orders"]["#{@orderId3sn}"]['bid']
        else
            flash[:notice] = "Order has no bid yet!"
        end
            
        
        #@nonMatchLine = Array.new
        @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = true#checkthis TODO
        @bid['lines'].each do |lineNum, val|
            if val != @po['lines'][lineNum]
               #@nonMatchLine << lineNum.to_i 
               flash[:error] = "PO line #{@nonMatchLine} does not match the bid. Check PO file"
               @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = false
               #@poNotMatchingBid = params['order']['po']
               #break
            end
        end
        
        #if @nonMatchLine.empty?
            if(params['order'].has_key? 'poFile' )
                poFile = params['order']['poFile']

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

                if not Dir.exists? (@orderId3sn)
                    FileUtils.mkdir(@orderId3sn)
                end
                FileUtils.cd(@orderId3sn)
                
                if not Dir.exists? ("poFile")
                    FileUtils.mkdir("poFile")
                end
                FileUtils.cd("poFile")

                File.open( poFile.original_filename, 'wb') do |file|
                    file.write(poFile.read)
                end 

                params['order']['poFile'] = poFile.original_filename
            end
            
            
            @project['orders']["#{@orderId3sn}"]["poLinesSubmittedBy"] = current_user['_id']
            @project['orders']["#{@orderId3sn}"]["poLinesSubmittedAt"] = Time.now

            @project['orders']["#{@orderId3sn}"]["poNumber"] = params['poNumber']
            @project['orders']["#{@orderId3sn}"]["poDate"] = params['poDate']
            @project['orders']["#{@orderId3sn}"]["poFile"] = params['order']['poFile']
            
            if not @project['orders']["#{@orderId3sn}"].has_key? 'po'
                @project['orders']["#{@orderId3sn}"]['po'] = Hash.new
                @project['orders']["#{@orderId3sn}"]['po']['lineAtts_poSpecific'] = Hash.new
            end
            
            
            @project['orders']["#{@orderId3sn}"]['po']['lineAtts_poSpecific'] = params['order']['po']['lineAtts_poSpecific']
            @project['orders']["#{@orderId3sn}"]['po'] = params['order']['po']
           
            $project_collection.save(@project) 
        #end
        
        
        @orderId3sn = params['orderId3sn']
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        redirect_to action: 'showSprintOrder', orderId3sn: @orderId3sn, id: @project['_id']
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
        redirect_to controller:'project', action: 'showMilestones', id: @project['_id']
    end
    
    def uploadMilestoneFile 
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        if(not @project.has_key? 'milestones')
            @project['milestones'] = Hash.new
        end
        if(params.has_key? 'project')
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
        else
            flash[:error] = "Error. Make sure a file was selected"
        end

        $project_collection.save(@project)
        
        redirect_to action: 'showMilestones'
    end
    
    def showMilestones
        
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
           
           
        id = params['id']
        @project = $project_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0]
        
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
            #nothing to do yet
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
    
    def editSprintOrder
        @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
        @orderId3sn = params['orderId3sn']
        
        order = @project['orders'][@orderId3sn]
        puts("order = #{order}")
        
        if(order.has_key? "bid")
            @prefillBid = order["bid"]
            if(order['bid'].has_key? 'lines')
                @numBidLines = order['bid']['lines'].size
            else
                @numBidLines = 0
            end
        else
            @numBidLines = 0
            @prefillBid = nil
        end
        
        if(order.has_key? 'po')
            @prefillPo = order['po']
            if(order['po'].has_key? 'lines')
                @numPoLines = order['po']['lines'].size
            else
                @numPoLines = 0
            end
        else
            @numPoLines = 0
            @prefillPo = nil
        end
        
        if(order.has_key? 'poDate')
            @poDate = Date.new(order['poDate']['poDate(1i)'].to_i, order['poDate']['poDate(2i)'].to_i, order['poDate']['poDate(3i)'].to_i)
        end

        gon.bidItemTypes = Array.new
        (1 .. @numBidLines).each do |i|
            itemType = order['bid']['lines'][i.to_s]['itemType']
            if(not itemType.empty? and not itemType.nil?)
                bidItemType = $itemType_collection.find_one({:_id => BSON::ObjectId(order['bid']['lines'][i.to_s]['itemType'])})
                gon.bidItemTypes << [{ 'name' => bidItemType['itemTypeName'], 'id'=> bidItemType['_id'].to_s }]
            else
                gon.bidItemTypes << nil
            end
            
        end
        
        gon.poItemTypes = Array.new
        (1 .. @numPoLines).each do |i|
            itemType = order['po']['lines'][i.to_s]['itemType']
            if(not itemType.empty? and not itemType.nil?)
                poItemType = $itemType_collection.find_one({:_id => BSON::ObjectId(order['po']['lines'][i.to_s]['itemType'])})
                gon.poItemTypes << [{ 'name' => poItemType['itemTypeName'], 'id'=> poItemType['_id'].to_s }]
            else
                gon.poItemTypes << nil
            end
            
        end
        
        #render :partial => 'project/sprintOrderLines', locals: {numlines: @numlines, orderId3sn: @orderId3sn, prefillBidOrPo: @prefillBidOrPo, bidOrPo: @bidOrPo  }
    end
    
    def edit
         @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
                  
         program = $program_collection.find_one({:_id => BSON::ObjectId(@project['program'])})
         gon.program = [{ 'name' => program['programName'], 'id'=> program['_id'].to_s }]
         
         projType = $projectType_collection.find_one({:_id => BSON::ObjectId(@project['projType'])})
         gon.projType = [{ 'name' => projType['projectTypeName'], 'id'=> projType['_id'].to_s }]

         customer = $customer_collection.find_one({:_id => BSON::ObjectId(@project['customerId'])})
         gon.customer = [{ 'name' => customer['customerName'], 'id'=> customer['_id'].to_s }]
         
         projManager = $person_collection.find_one({:_id => @project['projManager'].to_i}) #cause proj manager has the incremental ids assigned by controller not bson ids
         gon.projManager = [{ 'name' => projManager['name'], 'id'=> projManager['_id'].to_s }]
         
         projController = $person_collection.find_one({:_id => @project['projController'].to_i})
         gon.projController = [{ 'name' => projController['name'], 'id'=> projController['_id'].to_s }]
         
         @startDate = Date.new(@project['startDate(1i)'].to_i, @project['startDate(2i)'].to_i, @project['startDate(3i)'].to_i)
         
         @endDate = Date.new(@project['endDate(1i)'].to_i, @project['endDate(2i)'].to_i, @project['endDate(3i)'].to_i)
         
         @projectCustomerName = $customer_collection.find_one(:_id => BSON::ObjectId(@project['customerId']))['customerName']
         render "edit_#{@projectCustomerName}"
    end
    
    def updateOrder
        
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
        
        @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
        @orderId3sn = params["orderId3sn"]
        
        params['order']['createdAt'] = Time.now
        params['order']['createdBy'] = current_user['_id']
        
        @project['orders']["#{@orderId3sn}"] = params['order']
        
        $project_collection.save(@project)
        
        render 'showSprintOrder'
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
             if(not current_user.has_key? 'customerMode')
                 current_user['customerMode'] = Hash.new
                 current_user['customerMode']['customerId'] == "All Customers"
                 $person_collection.save(current_user)
             end
                 
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