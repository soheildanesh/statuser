class TodolistController < ApplicationController
        
    def new
        @projId = params['projId']
        splitDate = params['date'].split '-'
        @date = Time.new(splitDate[0], splitDate[1], splitDate[2])
        
    end
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def update
        #@existingList =  $todolist_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        newtodolist = params['todolist']
        newtodolist['_id'] = BSON::ObjectId(params['id'])
        tasks = newtodolist['tasks']
        
        if tasks["#{tasks.size-1}"]["description"].empty?
            @addNewTaskField = false
        else
            @addNewTaskField = true
        end
        
        timeMonthDay = newtodolist['date'].split ' '
        splitDate = timeMonthDay[0].split '-'
        @date = Time.new(splitDate[0], splitDate[1], splitDate[2])
        
        
        TodolistController.calcManHourStats! newtodolist        
        
        $todolist_collection.save(newtodolist)
        
        @todolist = newtodolist
        
        
        render 'show'
    end
    
    def self.calcManHourStats! newtodolist
        
        tasks = newtodolist['tasks']
        puts("tasks = #{tasks}")
        totalEstimatedManHours = 0.0
        totalEstManHoursForFinishedTasks = 0.0
        totalActualMH = 0.0
        tasks.each do |taskNum, taskAtts|

            totalEstimatedManHours = totalEstimatedManHours + taskAtts['estimated man hours'].to_i

            if(taskAtts["status"] == "Finished")
                totalActualMH = totalActualMH  + taskAtts['actual man hours'].to_i
                totalEstManHoursForFinishedTasks = totalEstManHoursForFinishedTasks + taskAtts['estimated man hours'].to_i
            end
        end
        
        newtodolist['total estimated man hours'] = totalEstimatedManHours
        newtodolist['total actual man hours'] = totalActualMH
        newtodolist['finished estimated man hours'] = totalEstManHoursForFinishedTasks
        newtodolist['estimated man hours left'] = totalEstimatedManHours - totalEstManHoursForFinishedTasks
        return newtodolist
    end
    
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def create
        puts(' in TodolistController.create')
        @todolist = params['todolist']
        @todolist['date'] = params['date']
        
        
        splitDate = @todolist['date'].split'-'
        @date = Time.new(splitDate[0], splitDate[1], splitDate[2])

     
        firstTask = @todolist['tasks']['0']
        if not firstTask.nil?
            if not firstTask.empty?
                @addNewTaskField = true
                
                @project = $project_collection.find({:_id => BSON::ObjectId(params['projectId']) } ).to_a[0]
                
                date = params['date']

                @todolist['projectId'] = @project['_id'].to_s
                @todolist['createdAt'] = Time.now
                @todolist['createdBy'] = get_current_user['_id'] 
                
                splitDate = params['date'].split '-'
                @todolist['date'] = Time.new(splitDate[0], splitDate[1], splitDate[2])
                
                
                TodolistController.calcManHourStats! @todolist
                
                id = $todolist_collection.insert(@todolist)
                
                
                if not @project.has_key? 'plan'
                    @project['plan'] = Hash.new
                end
                
                dateNoTime = date.to_s.split(' ')[0]
                if not @project['plan'].has_key? dateNoTime
                    @project['plan'][dateNoTime] = Hash.new #cuz project days are store as dates (year-month-day) but the date variable here is time (includes hours and such) and this is because mongo doesn't work with dates
                end
                @project['plan'][dateNoTime]['todolist_id'] = id 
                $project_collection.save(@project)
                
                render 'show'
                #redirect_to action: 'show', id: id
                
            end
        end
        
        #this is the case where nothing was added to the todo list?
        return
        
    end
    
    def show
        @todolist = $todolist_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]

        dateStr = @todolist['date'].to_s.split(' ')[0] #if 
        splitDate = dateStr.split'-'
        @date = Time.new(splitDate[0], splitDate[1], splitDate[2])
        
        @createdAt = @todolist['createdAt']
        @createdBy = @todolist['createdBy']
        
        tasks = @todolist['tasks']
        puts("tasks = #{tasks}")
        @totalEstimatedManHours = 0.0
        @totalEstManHoursForFinishedTasks = 0.0
        tasks.each do |taskNum, taskAtts|
            @totalEstimatedManHours = @totalEstimatedManHours + taskAtts['estimated man hours'].to_i
            if(taskAtts["status"] == "Finished")
                @totalEstManHoursForFinishedTasks = @totalEstManHoursForFinishedTasks + taskAtts['estimated man hours'].to_i
            end
        end
    end
        
    def index
       @todolists = $todolist_collection.find() 
    end
end