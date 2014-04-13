class WorkOrderController < ApplicationController
    def new
        #>>>this is when a new change request is being created which belongs to a work order
        if(params.has_key? 'woid')
            render 'change_request_inquiry'
        else    
            #this is when a regular work order is being created which belongs to a project
            @projctId = params['id']
        end
    end
    
    
    #note: the fact that a work order has a list of ids of its child wos and a project has a list of ids of its child wos means that if they have many many children the size of a project or wo object will be big. This runs agains the hard limit of mongodb file size and the less defined but importnat ram size of the server. Of course the usual way would be to ony have pointers (i.e. references to the ids of the parnt) from the children to parnt not the other way around (here we have both ways) but that means everytime we want a list of children we have to issue a query to choose the ones for the specific parnet, Practically it is unlikely to run agains the abovementioned limist because a project will have on the order of 10s of wo children and similarly a work order will have on the same order of children wos (aka change requests at this point) so we maintain both way pointers for performance. If a parnet has too many children we can potentially create a linked list of files containing child ids (april 2014, soheil)
    def create
        @wo = Hash.new()
        @wo = params['work_order']
        @wo['createdAt'] = Time.now
        woId = $wo_collection.insert(@wo)
        
        #A regular work order belongs to a project, but a change request (which starts with an authorization request) is a special kind of work order that belongs to another work order hence skipping this part if has key parnetWoId
        if  @wo.has_key? 'parentWoId'
            parentWo = $wo_collection.find({ :_id => BSON::ObjectId(@wo['parentWoId']) }).to_a[0]
            parentWo["childWo_id_#{woId}"] = woId
            $wo_collection.save(parentWo)
            redirect_to controller: 'work_order', action: 'show', id:@wo['parentWoId']
        else
            project = $project_collection.find({ :_id => BSON::ObjectId(@wo['projectId']) }).to_a[0]
            project["wo_id_#{woId}"] = woId
            $project_collection.save(project)
            redirect_to controller: 'project', action: 'show', id:@wo['projectId']
        end
    end
    
    def show
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        
        @childCrInquiries = Array.new
        @childWos = Array.new
        @hasQuote = false
        @wo.each do |key, value|
            if(key.include? 'childWo_id')
                @childWos << $wo_collection.find(:_id => value).to_a[0]
            elsif(key.include? 'quoteId')
                @hasQuote = true
            end
        end
        
        puts("@childWos = #{@childWos}")

        if not @childWos.nil? 
            @childWos.sort!{|x,y| y['createdAt'] <=> x['createdAt']} 
        end
        
        @childHierarchy= Hash.new
        
        #build hierarchy from each post's type
        for child in @childWos
            pointer = @childHierarchy
            
            if(child.has_key? 'type')
                childTypology = child['type'].split('>')
            
                #traverse down the hierarchy
                for type in childTypology 
                    if not pointer.has_key? type
                        pointer[type] = Hash.new
                    end
                    
                    if not pointer[type].has_key? 'count'
                        pointer[type]['count'] = 1
                    else
                        pointer[type]['count'] = pointer[type]['count'] + 1
                    end
                    
                    pointer = pointer[type]
                end
            
                #place child in the leaf
                if(pointer['leaves'].nil?)
                    pointer['leaves'] = Array.new
                end
                pointer['leaves'] << child
                
                #count number of granted change requests (to be used in ui)
                if(not child['grant'].nil? and child['grant']['status'] == "granted")
                    if(pointer['grantCount'].nil?)
                        pointer['grantCount'] = 1
                    else
                        pointer['grantCount'] = pointer['grantCount'] + 1
                    end
                end
            end
        end
    end
    
    def showChildWos
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        @childCrInquiries = Array.new
        @childWos = Array.new
        @wo.each do |key, value|
            if(key.include? 'childWo_id')
                @childWos << $wo_collection.find(:_id => value).to_a[0]
            end
        end

        if not @childWos.nil? 
            @childWos.sort!{|x,y| y['createdAt'] <=> x['createdAt']} 
        end
        
        @childHierarchy= Hash.new
        
        for child in @childWos
            pointer = @childHierarchy

            childTypology = child['type'].split('>')
            
            #traverse down the hierarchy
            for type in childTypology 
                if not pointer.has_key? type
                    pointer[type] = Hash.new
                end
                 pointer = pointer[type]
            end
            
            #place child in the leaf
            if pointer['leaves'].nil?
                pointer['leaves'] = Array.new
            end
            pointer['leaves'] << child    
        end
    end
    
    def updateWoAcceptance
        wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]

        woAcceptance = params['work_order']['woAcceptance']

        woAcceptance['created_at'] = Time.now
        woAcceptance['created_by'] = current_user['_id']
        
        wo['woAcceptance'] = woAcceptance
        
        $wo_collection.save(wo)

         redirect_to action: 'show', id: wo['_id'].to_s

    end
    
    def updateGrantStatus
        wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
        grant = params['work_order']['grant']
        
        grant['created_at'] = Time.now
        grant['created_by'] = current_user['_id']
        
        wo['grant'] = grant
        
        $wo_collection.save(wo)
        
        redirect_to action: 'show', id: wo['_id'].to_s
    end
    
    def showWoAcceptance
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
    end
    
    def showGrant
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
    end
    
    def showGrcr
        @wo = $wo_collection.find({ :_id => BSON::ObjectId(params['id']) }).to_a[0]
    end
    
    def addGrcr
        wo = $wo_collection.find({ :_id => BSON::ObjectId(params['woId']) }).to_a[0]

        grcr = params['grcr']
        grcr['createdAt'] = Time.now
        grcr['createdBy'] = current_user['_id']
        
        wo['grcr'] = grcr
        
        $wo_collection.save(wo)
        
        redirect_to action: 'show', id: wo['_id'].to_s
    end
    
    def addCpo
        cpo = params['cpo']

        cpo['createdAt'] = Time.now
        cpo['createdBy'] = current_user['_id']
        
        wo = $wo_collection.find({ :_id => BSON::ObjectId(params['woId']) }).to_a[0]
        #todo check and reject if wo already has cpo
        puts("cpo = #{cpo}")
        puts("wo = #{wo}")
        
        wo['cpo'] = cpo
        

        $wo_collection.save(wo)
        
        redirect_to action: 'show', id: wo['_id'].to_s
        
    end
    
    def newChangeRequest
        @parentWoId = params['id']
    end
    
    def newPreApprovalRequest
        @parentWoId = params['id']
        @type = params['type']
    end
    
    def newAuthorizationRequest
        @parentWoId = params['id']
        @type = params['type']
    end
    
    def newPreapprovalRequest
        
    end
    
    
end