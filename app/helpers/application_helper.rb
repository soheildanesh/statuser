module ApplicationHelper
    
    def validateCrew spaceSeparatedEmails
        emails = spaceSeparatedEmails.split()
        for email in emails
            email.downcase!
            if($person_collection.find({:email => email}).to_a[0].nil?)
                flash.now[:error] = "the email '#{email}' does not exist in the database so your input was not accepted, contact an admin if necessary"
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
            flash.now[:error] = "The site id you entered does not match an existing site, let someone with admin rights know if a new site needs to be created"
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
