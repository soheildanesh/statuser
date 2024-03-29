module ApplicationHelper
    
    #make sure user is logged in
    
    def ensureUserLoggedIn
        if(get_current_user.nil?)
            not get_current_user[:notice] = "User not logged in"
            render controller: 'login_session', action: 'new'
            return
        end
    end
    
    
    #sprint functions
    def getTotalForOrder order
        if(order.has_key? 'bid') 
            bid = order['bid']
            if bid.has_key? 'lines'
                lines = bid['lines']
                total = 0
                lines.each do |linNum,  orderLine|
                    total = total + orderLine['totalPrice'].to_f
                end
                return total
            end
        end
        return 0
    end
    #################
    
    
    def getCustomerMode
        if(get_current_user['customerMode']['customerId'] == "All Customers")
            return get_current_user['customerMode']['customerId']
        else
            return $customer_collection.find_one( :_id => BSON::ObjectId(get_current_user['customerMode']['customerId']))["customerName"]
        end
    end
    
    #generate a small 6 digit id that is unique in the passed in collection
    def genSamllUniqId collection, columnName = 'id3s'
        #generate a unique random 3s id
        id3s = rand(1000000)
        idIsUniq = false
        while(not idIsUniq)
          dup = collection.find({columnName => id3s }).to_a[0]
          if(dup.nil?)
              idIsUniq = true
          elsif(dup.empty?)
              idIsUniq = true
          else
              id3s = rand(1000000)
              puts("Trying to generate uniqe random 3sId for #{collection.name}")
          end
        end
        
        return id3s
    end
    
    #prints string or _ if nil or empty
    def printReplaceEmpty str
       if  str.nil? 
           str = "_"
       elsif str.empty?
           str = "_"
       end

       return str
    end
    
    def getNameFromBsonId collection,  nameColumnName, id
        begin 
            puts("collection = #{collection}, nameColumnName= #{nameColumnName} and id = #{id}")
            a = collection.find({:_id => BSON::ObjectId( id ) } ).to_a
            return a[0][nameColumnName]
        rescue 
            puts("ERROR: invalid  mongodb id format, or something else, in  getNameFromBsonId")
            return id
        end
    end
    
    def getProgramName programId
        begin 
            a = $program_collection.find({:_id => BSON::ObjectId( programId ) } ).to_a
            return a[0]['programName']
        rescue 
            puts("ERROR: invalid program mongodb id format in  getProgramName")
            return programId
        end
    end
    
    def getPersonEmail personId
        a = $person_collection.find({"_id" => personId.to_i}).to_a
        if(!a.nil? and !a.empty?)
            return a[0]['email']
        else
            ""
        end
    end
    
    def linkToPerson personId
        a = $person_collection.find({"_id" => personId.to_i}).to_a
        if(!a.nil? and !a.empty?)
            return (link_to a[0]["email"], :controller => 'person', :action => 'show', :id => personId.to_i)
        else
            ""
        end
    end
    
    
    
    def validateCrew spaceSeparatedEmails
        emails = spaceSeparatedEmails.split()
        for email in emails
            email.downcase!
            if($person_collection.find({:email => email}).to_a[0].nil?)
                not get_current_user.now[:error] = "the email '#{email}' does not exist in the database so your input was not accepted, contact an admin if necessary"
                redirect_to '/log_entry'
                return false
            end 
        end
        
        return true
    end
    
    def siteExists? siteId
        #check to see if the site id is valid
        existingSite = $site_collection.find({:siteId => siteId}).to_a[0]
        if(existingSite.nil?)
            not get_current_user.now[:error] = "The site id you entered does not match an existing site, let someone with admin rights know if a new site needs to be created"
            redirect_to '/log_entry'
            return false
        end
        
        return true
    end
    
    def isStringNumbersOnly? s
        digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0" ]
        s.split("").each do |i|
            if( !digits.include?(i) )
                return false
            end
        end
    end

end
