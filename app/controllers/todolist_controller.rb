class TodolistController < ApplicationController
    def new
        
    end
    
    def create
        todolist = params['todolist']
        
        id = $todolist_collection.insert(todolist)
        
        redirect_to action: 'show', id: id
        
    end
    
    def show
        @todolist = $todolist_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        
        
    end
        
    def index
       @todolists = $todolist_collection.find() 
    end
end