class TasklistGeneratorController < ApplicationController
    
    def new
        @id = params["id"]
        @projectId = params["id"]
    end
    
    def newUpdateSpreadSheet
        @projectId = params["id"]
    end


    #UPLOAD TASK SPREAD SHEET CONTAINING MODIFICATIONS TO EXISTING TASK LIST (E.G. CHANGE REQUEST)
    #COLUMS (IN SPREAD SHEET): TASK # , TASK DESC. , UNIT, QUANTITY, PERCENTAGE OF TOTAL PRICE
    #FINDS TASK IN PROJECT TASKS THAT MATCH TASK #, UPDATES DESCRIPTION, QUANTITY AND TOTAL PRICE PERCENTAGE BUT NOT THINGS THAT MIGHT HAVE BEEN SET BY PROJECT MANAGER/COORDINATOR SUCH AS QUANTITY DONE OR START/DUE DATES
    def uploadUpdateSpreadSheet
        projectId = params['spreadSheet']['projectId']
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
          
        uploaded_io = params['spreadSheet']['taskFile']
        @s = open_spreadsheet(uploaded_io)
        
        updatedTasks = Hash.new
        for r in @s.first_row.to_i .. @s.last_row.to_i
            if not @s.row(r)[0].to_s.empty?
                taskNumber = Integer(@s.row(r)[0]).to_s
                updatedTasks[taskNumber] = { 'task number' => taskNumber,  'task' => @s.row(r)[1], 'unit' => @s.row(r)[2] ,'quantity' => @s.row(r)[3].to_s, 'value percentage' => @s.row(r)[4]  } 
#                updatedTasks[@s.row(r)[0].to_s] = { 'task number' => @s.row(r)[0],  'task' => @s.row(r)[1], 'unit' => @s.row(r)[2] ,'quantity' => @s.row(r)[3], 'value percentage' => @s.row(r)[4]  } 
            end    
        end
        
        @tasks = @project['tasks']
        
        updatedTasks.each do |taskNum, task|
            if @tasks.has_key? taskNum
                #Change an already existing task
                puts("WE HEAS **** chaning already existing tas")
                @tasks[taskNum]['task'] = task['task']
                @tasks[taskNum]['unit'] = task['unit'] 
                @tasks[taskNum]['quantity'] = task['quantity']
                @tasks[taskNum]['value percentage'] = task['value percentage']
            else
                #Add a new task
                @tasks[taskNum] = task
            end
        end
        @project['tasks'] = @tasks
        @tasksArray = @tasks.values
        if @project.has_key? 'earned value'  
            @project['earned value'] = 0
        end
        $project_collection.save(@project)
        render 'update'
    end
    
    #UPLOAD NEW TASK SPREAD SHEET FOR PROJECT
    #COLUMS (IN SPREAD SHEET): TASK DESC. , UNIT, QUANTITY, PERCENTAGE OF TOTAL PRICE
    #NOTE: for updating existing task list see uploadUpdateSpreadSheet
    def uploadSpreadSheet  
        projectId = params['spreadSheet']['projectId']
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
          
        uploaded_io = params['spreadSheet']['taskFile']
        @s = open_spreadsheet(uploaded_io)
        
        @tasks = Hash.new
        for r in @s.first_row.to_i .. @s.last_row.to_i
            if not @s.row(r)[0].to_s.empty?
                taskNumber = Integer(@s.row(r)[0]).to_s
                @tasks[taskNumber] = { 'task number' => taskNumber,  'task' => @s.row(r)[1], 'unit' => @s.row(r)[2] ,'quantity' => @s.row(r)[3].to_s, 'value percentage' => @s.row(r)[4]  } 
                #@tasks[r.to_s] = { 'task number' => r.to_s,  'task' => @s.row(r)[0], 'unit' => @s.row(r)[1] ,'quantity' => @s.row(r)[2], 'value percentage' => @s.row(r)[3]  } 
            end    
        end
        
        if not @project.has_key? 'tasks'
           @project['tasks'] = Hash.new 
        end
        
        @project['tasks'] = @tasks
        @tasksArray = @tasks.values
        if @project.has_key? 'earned value'  
            @project['earned value'] = 0
        end
        $project_collection.save( @project )
        
        render 'update'
    end
    
    def sortByTime
        @project = $project_collection.find({:_id => BSON::ObjectId(params['projectId'].to_s) } ).to_a[0]
        @tasks = @project['tasks']
        if params.has_key? 'sort by start time' and params['sort by start time'] == 'true'
            #@tasks = @tasks.sort_by{ |taskNum, task| task["start date"]}
            tasksArr = @tasks.to_a
            tasksWithNoStartDate = Array.new
            tasksWithStartDate = Array.new
            #@tasks.each do |taskNum, task|
            for tasknum_task in tasksArr
                task = tasknum_task[1]
                if not task.has_key? 'start date'
                    tasksWithNoStartDate << task
                else
                    tasksWithStartDate << task
                end 
            end
            tasksWithStartDate.sort!{|x,y| 
                Time.new(x["start date"].to_s.split('-')[0], x["start date"].to_s.split('-')[1], x["start date"].to_s.split('-')[2].split()[0]) <=> Time.new(y["start date"].to_s.split('-')[0], y["start date"].to_s.split('-')[1], y["start date"].to_s.split('-')[2].split()[0])}
                
            @tasksArray = tasksWithStartDate.concat tasksWithNoStartDate
            
            
        elsif params.has_key? 'sort by due date' and params['sort by due date'] == 'true'
            tasksArr = @tasks.to_a
            tasksWithNoDueDate = Array.new
            tasksWithDueDate = Array.new
            for tasknum_task in tasksArr
                task = tasknum_task[1]
                if not task.has_key? 'dueDate'
                    tasksWithNoDueDate << task
                else
                    tasksWithDueDate << task
                end 
            end
            tasksWithDueDate.sort!{|x,y| 
                Time.new(x["dueDate"].to_s.split('-')[0], x["dueDate"].to_s.split('-')[1], x["dueDate"].to_s.split('-')[2].split()[0]) <=> Time.new(y["dueDate"].to_s.split('-')[0], y["dueDate"].to_s.split('-')[1], y["dueDate"].to_s.split('-')[2].split()[0])}
                
            @tasksArray = tasksWithDueDate.concat tasksWithNoDueDate
            
        end
        
        render 'update'
    end
    
    
    def update
        #TODO check user role
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @tasks = @project['tasks']
        
        
        #### MODIFY CHECKLIST SELECTED TASKS IF ANY #######
        selectedTasks = params['tasks']
        
        action = params['actionSelect']
        
        if not selectedTasks.nil?
            selectedTasks.each do |taskNum, theNumberOne_dummy|
            
                if action == 'set due date' and params.has_key? 'due date'
                    duedateHash = params['due date']
                    @tasks[taskNum]['dueDate'] = Time.new(duedateHash["date(1i)"], duedateHash["date(2i)"], duedateHash["date(3i)"])
                    @tasks[taskNum]['dueDate set by'] = get_current_user['_id']
                    @tasks[taskNum]['dueDate set at'] = Time.now
                end
                
                if action == 'set start date' and params.has_key? 'start date'
                    startDateHash = params['start date']
                    @tasks[taskNum]['start date'] = Time.new(startDateHash["date(1i)"], startDateHash["date(2i)"], startDateHash["date(3i)"])
                    @tasks[taskNum]['start date set by'] = get_current_user['_id']
                    @tasks[taskNum]['start date set at'] = Time.now
                    
                end
            
                if action == 'mark done'
                    @tasks[taskNum]['isDone'] = true
                    @tasks[taskNum]['makred done by'] = get_current_user['_id']
                    @tasks[taskNum]['marked done at'] = Time.now
                end
                
                 if action == 'undo mark done'
                    @tasks[taskNum]['isDone'] = false
                    @tasks[taskNum]['undo mark done by'] = get_current_user['_id']
                    @tasks[taskNum]['undo mark done at'] = Time.now
                 end
            end
        end
        #### MODIFY CHECKLIST SELECTED TASKS IF ANY #######
        
        
        #### STORE ANY UPLOADED TASK FILES ################
        taskFiles = params['taskFiles']
        
        if not taskFiles.nil?
            taskFiles.each do |taskNum, taskfile|
                FileUtils.cd(Rails.root)
                FileUtils.cd('public')
                if(not FileUtils.pwd().split("/").last == "uploads")
                    FileUtils.cd('uploads')
                end

                if not Dir.exists? ("#{@project['projId3s']}__#{@project['_id'].to_s}")
                    FileUtils.mkdir("#{@project['projId3s']}__#{@project['_id'].to_s}")
                end
                FileUtils.cd("#{@project['projId3s']}__#{@project['_id'].to_s}")  
                
                if not Dir.exists? ("tasknum_#{taskNum}")
                    FileUtils.mkdir("tasknum_#{taskNum}")
                end
                FileUtils.cd("tasknum_#{taskNum}")  
                
                File.open( taskfile.original_filename , 'wb') do |file|
                    file.write(taskfile.read)
                end 
                
                if not @tasks[taskNum].has_key? 'files'
                    @tasks[taskNum]['files'] = Hash.new
                end
                numExistingTaskFiles = @tasks[taskNum]['files'].size
                @tasks[taskNum]['files'][numExistingTaskFiles.to_s] = taskfile.original_filename
            end
                
        end
        #### STORE ANY UPLOADED TASK FILES ################

        #### STORE ANY NEW TASK COMMENTS ################
        taskComments = params['taskComments']
        if not taskComments.nil?
           taskComments.each do |taskNum, comment|
               
                       
               puts("tasNum = #{taskNum.to_i}")
               puts("tasks = #{@tasks}")
               
               
               @tasks[taskNum]['comment'] = comment
           end 
        end
        #### STORE ANY NEW TASK COMMENTS ################        
        
        
        #### UPDATE QUANITY DONE IF ANY UPDATED ##########
        quantity_done = params['quantity_done']        
        if not quantity_done.nil?
            quantity_done.each do |taskNum, qdone|
                @tasks[taskNum]['quantity_done'] = qdone
            end 
        end
        #### UPDATE QUANITY DONE IF ANY UPDATED ##########
        
        $project_collection.save(@project)
        @tasksArray = @tasks.values
        
    end
    
    def show
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @tasks = @project['tasks']
        if not @tasks.nil?
            @tasksArray = @tasks.values
        else
            @tasksArray = nil
        end
        
        render 'update'
    end
    
        
    def showTaskFiles
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @taskNum = params['taskNum']
        @task = @project['tasks'][@taskNum]
        
    end
    
    def deleteTaskFile
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @taskNum = params["taskNum"]
        @fileNum = params['fileNum']
        puts(">>> project = #{@project}")
        puts(">>> taskNum = #{@taskNum}")
        puts(">>> fileNum = #{@fileNum}")
        
        @task = @project['tasks'][@taskNum]
        puts(">>> @task = #{@task}")
        @fileName = @task["files"][@fileNum]
        #@task["files"][@fileNum] = "deleted_#{@fileName}_#{Time.now}_#{get_current_user['_id']}"
        @task["files"].delete(@fileNum)
        $project_collection.save(@project)

        
        #rename the file
        FileUtils.cd(Rails.root)
        FileUtils.cd('public')
        if(not FileUtils.pwd().split("/").last == "uploads")
            FileUtils.cd('uploads')
        end
        FileUtils.cd("#{@project['projId3s']}__#{@project['_id'].to_s}")  
        FileUtils.cd("tasknum_#{@taskNum}")  
        puts(">>> @fileName = #{@fileName}")
        FileUtils.mv("#{@fileName}", "deleted_#{Time.now}_by_#{get_current_user['_id']}__#{@fileName}")
        
        render 'showTaskFiles'
    end
    
    
    
    
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
          when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
          when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
          when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
      else 
          raise "Unknown file type: #{file.original_filename}"
      end
    end
    
    
    
    
end