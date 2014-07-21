class TodolistController < ApplicationController
        
    def new
        @projId = params['projId']
        @date = params['date']
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
        
        
        calcManHourStats! newtodolist        
        
        $todolist_collection.save(newtodolist)
        
        @todolist = newtodolist
        
        
        render 'show'
    end
    
    def calcManHourStats! newtodolist
        
        tasks = newtodolist['tasks']
        puts("tasks = #{tasks}")
        @totalEstimatedManHours = 0.0
        @totalEstManHoursForFinishedTasks = 0.0
        tasks.each do |taskNum, taskAtts|

            @totalEstimatedManHours = @totalEstimatedManHours + taskAtts['estimated man hours'].to_i
            
            if(taskAtts["status"] == "Finished")
                @totalEstManHoursForFinishedTasks = @totalEstManHoursForFinishedTasks + taskAtts['estimated man hours'].to_i
            end
        end
        
        newtodolist['total estimated man hours'] = @totalEstimatedManHours
        newtodolist['finished estimated man hours'] = @totalEstManHoursForFinishedTasks
        newtodolist['estimated man hours left'] = @totalEstimatedManHours - @totalEstManHoursForFinishedTasks
        return newtodolist
    end
    
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def create
        @todolist = params['todolist']
        
        
        
        firstTask = @todolist['tasks']['0']
        if not firstTask.nil?
            if not firstTask.empty?
                @addNewTaskField = true
                
                @project = $project_collection.find({:_id => BSON::ObjectId(params['projectId']) } ).to_a[0]
                
                date = params['date']

                @todolist['projectId'] = @project['_id'].to_s
                @todolist['createdAt'] = date
                
                calcManHourStats! @todolist
                
                id = $todolist_collection.insert(@todolist)
                
                
                if not @project.has_key? 'plan'
                    @project['plan'] = Hash.new
                end
                
                if not @project['plan'].has_key? date
                    @project['plan'][date] = Hash.new
                end
                @project['plan'][date]['todolist_id'] = id 
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
        
        tasks = @todolist['tasks']
        puts("tasks = #{tasks}")
        @totalEstimatedManHours = 0.0
        @totalEstManHoursForFinishedTasks = 0.0
        tasks.each do |taskNum, taskAtts|
            puts('***')
            puts(taskAtts)
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