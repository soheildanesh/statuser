class TasklistGeneratorController < ApplicationController
    def new
        @projectId = params['id']
    end
    
    def uploadSpreadSheet  
        projectId = params['spreadSheet']['projectId']
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
          
        uploaded_io = params['spreadSheet']['taskFile']
        @s = open_spreadsheet(uploaded_io)
        
        @tasks = Hash.new
        for r in @s.first_row.to_i .. @s.last_row.to_i
            if not @s.row(r)[0].to_s.empty?
                @tasks[r.to_s] = { 'task number' => r.to_s,  'task' => @s.row(r)[0], 'unit' => @s.row(r)[1] ,'quantity' => @s.row(r)[2], 'value percentage' => @s.row(r)[3]  } 
            end    
        end
        
        if not @project.has_key? 'tasks'
           @project['tasks'] = Hash.new 
        end
        
        @project['tasks'] = @tasks
        
        $project_collection.save( @project )
        
        render 'update'
    end
    
    def sortByTime
        @project = $project_collection.find({:_id => BSON::ObjectId(params['projectId'].to_s) } ).to_a[0]
        @tasks = @project['tasks']
        if params.has_key? 'sort by start time' and params['sort by start time'] == 'true'
            @tasks = @tasks.sort_by{ |taskNum, task| task["start date"]}
            
            #tasksWithNoStartDate = Array.new
            #tasksWithStartDate = Array.new
            #@tasks.each do |taskNum, task|
            #    if not task.has_key? 'start date'
            #        tasksWithNoStartDate << task
            #    else
            #        tasksWithStartDate << task
            #    end 
            #end
            #tasksWithStartDate.sort!{|x,y| 
            #    Time.new(x["start date"].to_s.split('-')[0], x["start date"].to_s.split('-')[1], x["start date"].to_s.split('-')[2].split()[0]) <=> Time.new(y["start date"].to_s.split('-')[0], y["start date"].to_s.split('-')[1], y["start date"].to_s.split('-')[2].split()[0])}
                
            #@tasks = tasksWithStartDate.concat tasksWithNoStartDate
            
        elsif params.has_key? 'sort by due date' and params['sort by due date'] == 'true'
            
            tasksWithNoDueDate = Array.new
            tasksWithDueDate = Array.new
            for task in @tasks
                if not task.has_key? 'dueDate'
                    tasksWithNoDueDate << task
                else
                    tasksWithDueDate << task
                end 
            end
            tasksWithDueDate.sort!{|x,y| 
                Time.new(x["dueDate"].to_s.split('-')[0], x["dueDate"].to_s.split('-')[1], x["dueDate"].to_s.split('-')[2].split()[0]) <=> Time.new(y["dueDate"].to_s.split('-')[0], y["dueDate"].to_s.split('-')[1], y["dueDate"].to_s.split('-')[2].split()[0])}
                
            @tasks = tasksWithDueDate.concat tasksWithNoDueDate
            
        end
        
        render 'update'
    end
    
    
    def update
        #TODO check user role
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @tasks = @project['tasks']
        
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

        
        taskComments = params['taskComments']
        if not taskComments.nil?
           taskComments.each do |taskNum, comment|
               
                       
               puts("tasNum = #{taskNum.to_i}")
               puts("tasks = #{@tasks}")
               
               
               @tasks[taskNum]['comment'] = comment
           end 
        end
        
        quantity_done = params['quantity_done']        
        if not quantity_done.nil?
            quantity_done.each do |taskNum, qdone|
                @tasks[taskNum]['quantity_done'] = qdone
            end 
        end
        
        $project_collection.save(@project)
        @tasksArray = @tasks.sort
        
        puts("tasksArray = #{@tasksArray}")
        
    end
    
    def show
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @tasks = @project['tasks']
        #@tasksArray = @tasks.sort
        
        render 'update'
    end
    
    def showTaskFiles
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @taskNum = params['taskNum']
        @task = @project['tasks'][@taskNum]
        
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