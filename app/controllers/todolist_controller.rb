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
        
        #tasks = Array.new
        #for task in newtodolist['tasks']
        #    if not task['description'].nil? and not task['description'].empty?
        #       tasks << task 
        #    end
        #end
        
        $todolist_collection.save(newtodolist)
        
        
        
        #calculate total estimated hours
        
        
        
        
        #oldtodolist = $todolist_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        
        #numTasks = oldtodolist['numTasks']
        
        
        
        #see if a new task was added or just old tasks edited
        #newTask = newtodolist['tasks'][numTasks] #work it out old task at index 0,new task at index 1, numTasks = 1,
        #byebug
        #if not newTask.nil?
        #    if not newTask.empty?
        #        oldtodolist['tasks'] = oldtodolist['tasks'].slice(0, numtasks + 1 )
        #        oldtodolist['numTasks'] = oldtodolist['numTasks'] + 1
        #        $todolist_collection.save(oldtodolist)
        #    else
        #        #no new task was added
        #    end
        #else
        #    #no new task was added
        #end
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