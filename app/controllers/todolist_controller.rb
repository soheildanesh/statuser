
#DAILY todo list to be more exact, each todolist has a date attr that is its day.
class TodolistController < ApplicationController
    def calcTotalEstimatedManHours todolist
        tasks = todolist['tasks']
        
        totalEstManHours = 0
        tasks.each {|taskNum, taskAttrs| 
            totalEstManHours = totalEstManHours + taskAttrs['estimated man hours'].to_i
            }
        return totalEstManHours
    end
    
    def new
        @projId = params['projId']
        
        #date is the day for this todo list, ie the day this is supposed to be done in 
        @date = params['date']
    end
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def update
        #@existingList =  $todolist_collection.find({:_id => BSON::ObjectId(params['id']) } ).to_a[0]
        newtodolist = params['todolist']
        newtodolist['_id'] = BSON::ObjectId(params['id'])
        
        totalEstManHours = calcTotalEstimatedManHours newtodolist
        newtodolist['totalEstManHours'] = totalEstManHours
        
        $todolist_collection.save(newtodolist)
        
        #calculate total estimated hours

        

        redirect_to action: 'show', id: newtodolist['_id']
     
    end
    
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def create
        todolist = params['todolist']
        
        
        
        firstTask = todolist['tasks']['0']
        if not firstTask.nil?
            if not firstTask.empty?
                
                
                @project =  @project = $project_collection.find({:_id => BSON::ObjectId(params['projectId']) } ).to_a[0]
                
                date = params['date']

                todolist['projectId'] = @project['_id']
                todolist['date'] = date
                
                totalEstManHours = calcTotalEstimatedManHours newtodolist
                todolist['totalEstManHours'] = totalEstManHours
                
                id = $todolist_collection.insert(todolist)
                
                
                
                if not @project.has_key? 'plan'
                    @project['plan'] = Hash.new
                end
                
                if not @project['plan'].has_key? date
                    @project['plan'][date] = Hash.new
                end
                @project['plan'][date]['todolist_id'] = id 
                $project_collection.save(@project)
                
                    
                
                redirect_to action: 'show', id: id
                
            end
        end
        
        return
        
    end
    
    def show
        @todolist = $todolist_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
    end
        
    def index
       @todolists = $todolist_collection.find() 
    end
end