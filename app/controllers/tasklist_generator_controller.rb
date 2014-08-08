class TasklistGeneratorController < ApplicationController
    def new
        @projectId = params['id']
    end
    
    def uploadSpreadSheet  
        projectId = params['spreadSheet']['projectId']
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
          
        uploaded_io = params['spreadSheet']['taskFile']
        @s = open_spreadsheet(uploaded_io)
        
        @tasks = Array.new
        for r in @s.first_row.to_i .. @s.last_row.to_i

            if false #TODO put antenna JCR form as an html form maybe
                if @s.row(r)[0].downcase.include? 'antenna install'
                    
                end
            end
           @tasks << { 'task number' => r.to_s, 'task' => @s.row(r)[0] } 
        end
        
        if not @project.has_key? 'tasks'
           @project['tasks'] = Hash.new 
        end
        
        @project['tasks'] = @tasks
        
        $project_collection.save( @project )
        
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
            selectedTasks.each do |taskNum, theNumberOne|
            
                if action == 'set due date' and params.has_key? 'dueDate'
                    @tasks[taskNum.to_i]['dueDate'] = params['dueDate']
                    @tasks[taskNum.to_i]['dueDate set by'] = get_current_user['_id']
                    @tasks[taskNum.to_i]['dueDate set at'] = Time.now
                end
            
                if action == 'mark done'
                    @tasks[taskNum.to_i]['isDone'] = true
                    @tasks[taskNum.to_i]['makred done by'] = get_current_user['_id']
                    @tasks[taskNum.to_i]['marked done at'] = Time.now
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
                
                if not @tasks[taskNum.to_i].has_key? 'files'
                    @tasks[taskNum.to_i]['files'] = Hash.new
                end
                numExistingTaskFiles = @tasks[taskNum.to_i]['files'].size
                @tasks[taskNum.to_i]['files'][numExistingTaskFiles.to_s] = taskfile.original_filename
            end
                
        end
        
        taskComments = params['taskComments']
        if not taskComments.nil?
           
           taskComments.each do |taskNum, comment|
               @tasks[taskNum.to_i]['comment'] = comment
           end 
        end
        
        
        $project_collection.save(@project)
        
    end
    
    def show
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @tasks = @project['tasks']
        
        render 'update'
    end
    
    def showTaskFiles
        projectId = params["id"]
        @project = $project_collection.find({:_id => BSON::ObjectId(projectId.to_s) } ).to_a[0]
        @taskNum = params['taskNum'].to_i
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