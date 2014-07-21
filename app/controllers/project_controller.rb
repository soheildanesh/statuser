class ProjectController < ApplicationController
    
    before_action :clearGon, :ensureUserLoggedIn
     
    #clear js variable gon, see gon gem 
    def clearGon
        gon.clear()
    end
    
    def showPlan
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        @startDate = Date.new( @project['startDate(1i)'].to_i, @project['startDate(2i)'].to_i, @project['startDate(3i)'].to_i)
        @endDate = Date.new( @project['endDate(1i)'].to_i, @project['endDate(2i)'].to_i, @project['endDate(3i)'].to_i)
        
    end
    
    
    
    ######
    def indexUnfinishedTasks
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        
        if not @project.has_key? 'plan'
            flash[:notice] = 'project has no plan!'
            redirect_to action: 'show', id: params['id']
            return 
        end
        
        @unfinishedTasks = Hash.new
        
        @project['plan'].each do |day, todolisIdHash|
            
            if Date.parse(day) >= Date.today
                next 
            end
            
            todolist = $todolist_collection.find({:_id => todolisIdHash['todolist_id'] } ).to_a[0]
            
            tasks = todolist['tasks']
            
            tasks.each do |taskNum, taskAtts|
                status = taskAtts['status']
                if status.nil? or status.empty? or status == "In Progress"
                   
                   if not @unfinishedTasks.has_key? day.to_s
                       @unfinishedTasks[day.to_s] = Hash.new
                   end
                   @unfinishedTasks[day.to_s][@unfinishedTasks[day.to_s].size.to_s] = taskAtts
                   
                end
            end
        end
        
    end
    
    def rescheduleTaskChooseNewDay
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        @startDate = Date.new( @project['startDate(1i)'].to_i, @project['startDate(2i)'].to_i, @project['startDate(3i)'].to_i)
        @endDate = Date.new( @project['endDate(1i)'].to_i, @project['endDate(2i)'].to_i, @project['endDate(3i)'].to_i)
        
        @originalDay = params['originalDay']
        @taskNum = params['taskNum']
        
    end
    
    def rescheduleTaskAssignToNewDay
        @params = params
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        @originalDay = params['taskToReschedule']['originalDay']
        @taskNum = params['taskToReschedule']['taskNum']
        @newDay = params['taskToReschedule']['newDay']
        
        #get task from original day
        @originalTodolistId = @project['plan']["#{@originalDay}"]["todolist_id"]
        @originalTodolist = $todolist_collection.find({ :_id => @originalTodolistId }).to_a[0]
        
        @task = @originalTodolist['tasks'][@taskNum.to_s]
        
        
        #assign to new day
        if not @project.has_key? 'plan'
            @project['plan'] = Hash.new
        end
        if @project['plan'].has_key? @newDay.to_s
            newDayTodoListid = @project['plan'][@newDay.to_s]['todolist_id']
            newDayTodoList = $todolist_collection.find({ :_id => newTodoListid }).to_a[0]
            numExsitingNewdayTasks = newDayTodoList['tasks'].size
            newDayTodoList['tasks'][numExsitingNewdayTasks] = @task
            $todolist_collection.save (newDayTodoList)
            id = newDayTodoList['_id']
        else
           @project['plan'][@newDay.to_s] = Hash.new
           todolist = { projectId:  @project['_id'].to_s, createdAt: Time.now, createdBy: get_current_user['_id'], tasks: {"0" => @task}}
           id = $todolist_collection.insert(todolist)
        end

        
        redirect_to controller: 'todolist', action: 'show', id: id
        
    end


    #sprint
    def milestone_files
        @milestone = params['milestone']
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id'])}).to_a[0]
    end
    def __milestone_files
        @milestone = params['milestone']
      
       
        puts("@project = #{@project} @milestone = #{@milestone}")
        #@milestone = @project['']
    end
    
    def createSprintOrder
        
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end

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
        params['order']['createdBy'] =get_current_user['_id']
        
        
        @project['orders']["#{ordCount}"] = params['order']
        
        $project_collection.save(@project)
        redirect_to controller:'project', action: 'indexSprintOrders', id: @project['_id']    
    end
    
    def editSprintOrder
        
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
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
    
    
    def showSprintOrder
        
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
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
        
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
        role =get_current_user['role']
        if role == 'admin' or role == 'project controller' or role == 'project manager' 
            @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        else
            @project = nil
            flash[:error] = "You are not authorized to see project orders!"
        end
        
    end
    
    def newSprintOrder
        
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        
        @orderCount = 1
        if( @project.has_key? 'orders')
            puts("project orders = #{@project['orders']}")
            @orderCount = @project['orders'].length + 1
        end
    end
    
    def addPoToSprintOrder
        
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        @project = $project_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        @orderId3sn = params['orderId3sn']
        
        if params.has_key? 'order'
            if params['order'].has_key? 'po'
                
            else
                flash[:error] = "Please submite PO lines!"
                redirect_to action: 'showSprintOrder', orderId3sn: @orderId3sn, id: @project['_id']
                return
            end
        else         
            flash[:error] = "Please submite PO lines!"
            redirect_to action: 'showSprintOrder', orderId3sn: @orderId3sn, id: @project['_id']
            return
        end
        
        @po = params['order']['po']
        puts("@project[orders][#{@orderId3sn}] = #{@project}['orders'][#{@orderId3sn}]")
        if @project["orders"]["#{@orderId3sn}"].has_key? 'bid'
            @bid = @project["orders"]["#{@orderId3sn}"]['bid']
        else
            flash[:notice] = "Order has no bid yet!"
        end
            
        
        @nonMatchLines = Array.new
        @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = true#checkthis TODO
        @bid['lines'].each do |lineNum, val|
            if val != @po['lines'][lineNum]
               @nonMatchLines << lineNum.to_i 
               flash[:error] = "PO line #{@nonMatchLine} does not match the bid. Check PO file"
               @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = false
               #@poNotMatchingBid = params['order']['po']
               #break
            end
        end
        
        if(not @nonMatchLines.empty? )
            @project['orders']["#{@orderId3sn}"]['nonMatchLines'] = @nonMatchLines
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
            
            
            @project['orders']["#{@orderId3sn}"]["poLinesSubmittedBy"] =get_current_user['_id']
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
        
        if(get_current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project controller' or role == 'project manager' or role == 'project manager admin')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
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
        
        if(get_current_user.nil?)
            flash[:notice] = "User not logged in"
            render controller: 'login_session', action: 'new'
            return
        end
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project controller' or role == 'project manager' or role == 'project manager admin')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
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
                @project['milestones'][milestone]["files"][(numExistingMsFiles+1).to_s] = {fileName: uploadedFile.original_filename , uploadTime: Time.now, uploadedBy:get_current_user['_id'] }
            end
            flash[:notice] = "File uploaded"
        else
            flash[:error] = "Error. Make sure a file was selected"
        end

        $project_collection.save(@project)
        
        redirect_to action: 'showMilestones'
    end
    
    def showMilestones
        
        if(get_current_user.nil?)
            flash[:notice] = "User not logged in"
            render :action => 'index'
            return
        end
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project controller' or role == 'project manager' or role == 'project manager admin')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
         #get the milestone dependecies list for this project. Each array in the array represents a depndecy. The first memebr is the milestone and the others are the ones it depends on ie its prereqs
 #[ ["m1"], ["m2", "m1"], ["m3", "m2"]]
        @milestoneDependecies =  [
           [{milestone: "Bid Invitation Received", number: 100}],
           [{milestone: "Pre-Bid Conference Complete", number: 105}, "Bid Invitation Received"],
           [{milestone: "Bid Walk Complete", number: 110}, "Pre-Bid Conference Complete"],
           [{milestone: "Bid Complete", number: 115}, "Bid Walk Complete"],
           [{milestone: "Bid Review Complete", number: 120}, "Bid Complete"],
           [{milestone: "SAP Submitted", number: 125}, "Bid Review Complete"],
           [{milestone: "SAP Approved", number: 130}, "SAP Submitted"],
           [{milestone: "Initial Bid POR Submitted", number: 135}, "SAP Approved"],
           [{milestone: "Initial Bid PO Received", number: 140}, "Initial Bid POR Submitted"],
           [{milestone: "NTP Received", number: 145}, "Initial Bid PO Received"],
           [{milestone: "Pre-Construction Visit Complete", number: 150}, "Initial Bid PO Received", "NTP Received"],
           [{milestone: "Cell Site Verification Complete", number: 155}, "Pre-Construction Visit Complete"],
           [{milestone: "Material Order Submitted", number: 160}, "Cell Site Verification Complete"],
           [{milestone: "Material Received", number: 165}, "Material Order Submitted"],
           [{milestone: "Equipment Pickup Complete", number: 170}, "Initial Bid PO Received", "NTP Received"],

           [{milestone: "Equipment Inventory Complete", number: 175}, "Equipment Pickup Complete"],
           [{milestone: "Construction Start", number: 200 }, "Equipment Inventory Complete", "Material Received"],

           [{milestone: "Change Request Submitted", number: 205}, "Construction Start"],
           [{milestone: "Change Request Approved", number: 210}, "Change Request Submitted"],
           [{milestone: "Change Request PO Received", number: 215}, "Change Request Approved"],
           [{milestone: "Ground Level Construction Complete", number: 220}, "Construction Start"],
           [{milestone: "Tower Level Construction Complete", number: 225} , "Construction Start"],
           [{milestone: "Commissioning & Integration Schedule Complete", number: 245}, "Ground Level Construction Complete", "Tower Level Construction Complete"],
           [{milestone: "Commissioning & Integration Complete", number: 250}, "Commissioning & Integration Schedule Complete"],
           [{milestone: "Sprint-Provided Punchlist Received", number: 255}, "Ground Level Construction Complete", "Tower Level Construction Complete"],
           [{milestone: "Punchlist Clean-up Complete", number: 260}, "Sprint-Provided Punchlist Received"],
           [{milestone: "Return of Unused Equipment Complete", number: 265}, "Ground Level Construction Complete", "Tower Level Construction Complete"],
           [{milestone: "Construction Documents Complete", number: 300}, "Punchlist Clean-up Complete", "Return of Unused Equipment Complete"],
           [{milestone: "Construction Documents Submitted", number: 305}, "Construction Documents Complete"],
           [{milestone: "Construction & Final Acceptance Checklist Complete", number: 310}, "Punchlist Clean-up Complete", "Return of Unused Equipment Complete"],
           [{milestone: "Construction Complete", number: 315}, "Construction Documents Submitted", "Construction & Final Acceptance Checklist Complete"],
           [{milestone: "Final Acceptance Documents Complete", number: 320}, "Construction Complete"],
           [{milestone: "Acceptance Request Submitted", number: 325}, "Final Acceptance Documents Complete"],
           [{milestone: "Final Acceptance", number: 330}, "Acceptance Request Submitted"]]
           
           
        id = params['id']
        @project = $project_collection.find({:_id => BSON::ObjectId(id) } ).to_a[0]
        
    end
    
    def new
        
        if(get_current_user.nil?)
            flash[:notice] = "User not logged in"
            render controller: 'login_session', action: 'new'
            return
        end
        role =get_current_user['role']
        if false and  not( role == 'admin' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
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
         
        render "show_#{@projectCustomerName.downcase}"
         
    end
    
    def destroy
        tobeDeleted = $project_collection.find({_id: params['id'].to_i}).to_a[0]
        if(get_current_user['role'] == 'admin' )#or tobeDeleted['createdBy'] ==get_current_user['_id'])
            $project_collection.remove({_id: BSON::ObjectId(params['id'])})
            redirect_to controller:'project', action:'index'
            return
        else
            flash[:error] = "you dont have permission to delete this entry, contact an admin"
            redirect_to controller:'project', action:'index'
            return
        end
    end
    
    def create
        
        if false and  not( role == 'admin' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        if( params['project'].nil? )
            return nil
        end
        
        #TODO check admin status so not just any one can create new proj
        
        #create new project and add quoteId to it
        @project = Hash.new()
        @project = params['project']
        @project['createdAt'] = Time.now
        @project['createdBy'] =get_current_user['_id']
        
        
        
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
        
        #check if dates are valid TODO
        

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
        
        #validate Date TODO
        if(false and okToCreate)
           #check to see if dates are valid
           begin
              Date.parse("31-02-2010")
           rescue ArgumentError
              # handle invalid date
           end 
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
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        @project = $project_collection.find({:_id => BSON::ObjectId( params['id']) } ).to_a[0]
                  
         program = $program_collection.find_one({:_id => BSON::ObjectId(@project['program'])})
         gon.program = [{ 'name' => program['programName'], 'id'=> program['_id'].to_s }]
         
         projType = $projectType_collection.find_one({:_id => BSON::ObjectId(@project['projType'])})
         gon.projType = [{ 'name' => projType['projectTypeName'], 'id'=> projType['_id'].to_s }]

         customer = $customer_collection.find_one({:_id => BSON::ObjectId(@project['customerId'])})
         gon.customer = [{ 'name' => customer['customerName'], 'id'=> customer['_id'].to_s }]
         
         projManager = $person_collection.find_one({:_id => @project['projManager'].to_i}) #cause proj manager has the incremental ids assigned by controller not bson ids
         gon.projManager = [{ 'name' => projManager['name'], 'id'=> projManager['_id'].to_s }]
         
         projManagerAdmin = $person_collection.find_one({:_id => @project['project manager admin'].to_i}) #cause proj manager has the incremental ids assigned by controller not bson ids
         gon.projManagerAdmin = [{ 'name' => projManagerAdmin['name'], 'id'=> projManagerAdmin['_id'].to_s }]
         
         projController = $person_collection.find_one({:_id => @project['projController'].to_i})
         gon.projController = [{ 'name' => projController['name'], 'id'=> projController['_id'].to_s }]
         
         @startDate = Date.new(@project['startDate(1i)'].to_i, @project['startDate(2i)'].to_i, @project['startDate(3i)'].to_i)
         
         @endDate = Date.new(@project['endDate(1i)'].to_i, @project['endDate(2i)'].to_i, @project['endDate(3i)'].to_i)
         
         @projectCustomerName = $customer_collection.find_one(:_id => BSON::ObjectId(@project['customerId']))['customerName']
         render "edit_#{@projectCustomerName}"
    end
    
    def updateOrder
        
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
        if(not get_current_user.nil?)
             if(not get_current_user['role'] == 'admin')
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
        params['order']['createdBy'] =get_current_user['_id']
        
        @project['orders']["#{@orderId3sn}"] = params['order']
        
        #if a po has been submitted check to see if po and bid are the same
        if @project['orders']["#{@orderId3sn}"].has_key? 'po'
            if @project['orders']["#{@orderId3sn}"]['po'].has_key? 'lines'
                @nonMatchLines = Array.new
                @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = true
                @project['orders']["#{@orderId3sn}"]['bid']['lines'].each do |lineNum, val|
                    if(@project['orders']["#{@orderId3sn}"]['po']['lines'].has_key? lineNum.to_s)
                        if val != @project['orders']["#{@orderId3sn}"]['po']['lines'][lineNum]
                            puts("val = #{val}")
                            puts("val po = #{@project['orders']["#{@orderId3sn}"]['po']['lines'][lineNum]}")
                            #po has that line but it doesn't match bid
                            @nonMatchLines << lineNum.to_i 
                            flash[:error] = "PO line #{@nonMatchLine} does not match the bid. Check PO file"
                            @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = false
                        end
                    else 
                        #po doesn't have that line
                        @nonMatchLines << lineNum.to_i 
                        flash[:error] = "PO line #{@nonMatchLine} does not match the bid. Check PO file"
                        @project['orders']["#{@orderId3sn}"]["matchingPoLinesSubmitted"] = false
                    end
                end
            end
            if(not @nonMatchLines.empty? )
                @project['orders']["#{@orderId3sn}"]['nonMatchLines'] = @nonMatchLines
            end
       end
                

        
        $project_collection.save(@project)
        
        render 'showSprintOrder'
    end
    
    def update
        role =get_current_user['role']
        if not( role == 'admin' or role == 'project manager' or role == 'project controller')
            flash[:error] = "User not authorized"
            redirect_to action: 'index'
            return
        end
        
        
        if(not get_current_user.nil?)
             if(not get_current_user['role'] == 'admin')
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
         
        if(get_current_user['customerMode']['customerId'] == "All Customers")
              @customerInMode = "All Customers"
         else
              @customerInMode = $customer_collection.find_one( {:_id => BSON::ObjectId(get_current_user['customerMode']['customerId']) } )['customerName']
         end
         if( get_current_user.nil?)
             flash[:notice] = "Have to be admin user for this"
             render '/login_session/new'
             return
         elsif( get_current_user['role'] == 'admin')
             if(not get_current_user.has_key? 'customerMode')
                get_current_user['customerMode'] = Hash.new
                get_current_user['customerMode']['customerId'] = "All Customers"
                 $person_collection.save( get_current_user)
             end

             if( get_current_user['customerMode']['customerId'] == "All Customers")
                 @projects = $project_collection.find().sort( :_id => :desc ).to_a
             else
                 @projects = $project_collection.find({"customerId" =>get_current_user['customerMode']['customerId'] }).sort( :_id => :desc ).to_a
             end
         elsif( get_current_user['role'].include? 'project')
             if( get_current_user['role'] == 'project manager')
                 if( get_current_user['customerMode']['customerId'] == "All Customers")
                     @projects = $project_collection.find({"projManager" =>get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 else
                     @projects = $project_collection.find({"customerId" =>get_current_user['customerMode']['customerId'] , "projManager" =>get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 end
             elsif( get_current_user['role'] == 'project controller')
                 if( get_current_user['customerMode']['customerId'] == "All Customers")
                     @projects = $project_collection.find({"projController" =>get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 else
                     @projects = $project_collection.find({"customerId" =>get_current_user['customerMode']['customerId'] , "projController" =>get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 end
             else
                 #the above two roles were added early, starting with project manager admin and later on roles the role will match the key in the project
                 if( get_current_user['customerMode']['customerId'] == "All Customers")
                     @projects = $project_collection.find( { get_current_user['role'] =>get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 else
                     @projects = $project_collection.find({"customerId" =>get_current_user['customerMode']['customerId'] , get_current_user['role'] => get_current_user['_id'].to_s }).sort( :_id => :desc ).to_a
                 end
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