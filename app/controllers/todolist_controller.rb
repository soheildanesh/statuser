class TodolistController < ApplicationController
    def new
        
    end
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def update
        @todolist = $todolist_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        
        numTasks = @todolist['numTasks']
        
        
        
        #see if a new task was added or just old tasks edited
        newTask = @todolist['tasks'][numTasks] #work it out old task at index 0,new task at index 1, numTasks = 1,
        if not newTask.nil?
            if not newTask.empty?
                todolist['tasks'] = todolist['tasks'].slice(0, numtasks + 1 )
                $todolist_collection.save(todolist)
            else
                #no new task was added
            end
        else
            #no new task was added
        end
        redirect_to action: 'show', id: todolist['_id']
     
    end
    
    
    #because each time the focus changes to a new text box the form is submitted, we are guaranteed to have only one new task on each form submission
    def create
        todolist = params['todolist']
        
        firstTask = todolist['tasks']['0']
        if not firstTask.nil?
            if not firstTask.empty?
                id = $todolist_collection.insert(todolist)
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