require 'token'
require 'cgi'
require 'json'

module SFRequest

  INSTANCE_URL = 'https://na8.salesforce.com/services/data/v21.0/'

  def SFRequest.get_news_feed
    query = 'SELECT FeedPost.Body, 
                    CreatedDate, 
                    CreatedBy.Name, 
                    FeedPost.CreatedBy.SmallPhotoUrl 
             FROM NewsFeed 
             WHERE (Type <> \'Content\' AND Type <> \'TrackedChange\') 
             LIMIT 4'

    response = JSON.parse(Token::get_token.get("#{INSTANCE_URL}query/?q=#{CGI::escape(query)}"))
    return response
  end

  def SFRequest.get_sticky_notes
    query = 'SELECT Id,
                    Body__c,
                    Hours__c,
                    Owner__c,
                    Project__c,
                    Status__c,
                    Sprint__c
             FROM StickyNote__c
             ORDER BY Status__c
             LIMIT 100'
    
    response = JSON.parse(Token::get_token.get("#{INSTANCE_URL}query/?q=#{CGI::escape(query)}"))
  end

  def SFRequest.search keyword
    query = "FIND {*#{keyword}*} 
             IN ALL FIELDS 
             RETURNING Account(Id,Name),
                       Contact(Id,Name),
                       Lead(Id,Name),
                       FeedPost(Id,Body)"

    json = JSON.parse(Token::get_token.get("#{INSTANCE_URL}search?q=#{query}"))

    response = {'Open' => {}, 'In Progress' => {}, 'Resolved' => {}, 'Closed' => {}}
    open = ''
    json["records"].each do |r|
      case r["Status__c"]
        when 'Open'
          open += "{'Project__c' => #{r["Project__c"]}}"
      end
    end

    return response
  end

  def SFRequest.get_sobjects type
    uri = "#{INSTANCE_URL}query/?q="

    case type
      when 'Account'
        uri += "SELECT Id,
                       Name
                FROM Account 
                LIMIT 100"
      when 'Contact'
        uri += "SELECT Id,
                       Name
                FROM Contact 
                LIMIT 100"
      when 'Lead'
        uri += "SELECT Id,
                       FirstName,
                       LastName
                FROM Lead 
                LIMIT 100"
    end

    response = JSON.parse(Token::get_token.get(uri))
    return response
  end

  def SFRequest.get_sobject id, type
    uri = "#{INSTANCE_URL}query/?q="

    case type
      when 'Account'
        uri += "SELECT Id, 
                       Name, 
                       Website,
                       Phone, 
                       Description, 
                       BillingStreet, 
                       BillingState,  
                       BillingCountry, 
                       BillingCity 
                FROM Account 
                WHERE Id = '#{id}' 
                LIMIT 1"
      when 'Contact'
        uri += "SELECT Id, 
                       Phone, 
                       MailingStreet, 
                       MailingState, 
                       MailingCountry, 
                       MailingCity, 
                       LastName, 
                       FirstName, 
                       Email, 
                       Description 
                FROM Contact 
                WHERE Id = '#{id}' 
                LIMIT 1"
      when 'Lead'
        uri += "SELECT Id, 
                       Street, 
                       State, 
                       LastName, 
                       FirstName, 
                       Email, 
                       Description, 
                       Country, 
                       Company, 
                       City 
                FROM Lead 
                WHERE Id = '#{id}' 
                LIMIT 1"
    end

    response = JSON.parse(Token::get_token.get(uri))
    return response
  end

  def SFRequest.update_sobject sobject, type
    params_json = ""

    case type
      when 'Account'
        params_json = "{
                        \"Name\":\"#{sobject["Name"]}\",
                        \"Phone\":\"#{sobject["Phone"]}\",
                        \"Website\":\"#{sobject["Website"]}\",
                        \"BillingStreet\":\"#{sobject["BillingStreet"]}\",
                        \"BillingState\":\"#{sobject["BillingState"]}\",
                        \"BillingCountry\":\"#{sobject["BillingCountry"]}\",
                        \"BillingCity\":\"#{sobject["BillingCity"]}\",
                        \"Description\":\"#{sobject["Description"]}\"
                      }"
      when 'Contact'
        params_json = "{
                        \"FirstName\":\"#{sobject["FirstName"]}\",
                        \"LastName\":\"#{sobject["LastName"]}\",
                        \"Phone\":\"#{sobject["Phone"]}\",
                        \"Description\":\"#{sobject["Description"]}\",
                        \"MailingStreet\":\"#{sobject["MailingStreet"]}\",
                        \"MailingState\":\"#{sobject["MailingState"]}\",
                        \"MailingCountry\":\"#{sobject["MailingCountry"]}\",
                        \"MailingCity\":\"#{sobject["MailingCity"]}\",
                        \"Email\":\"#{sobject["Email"]}\"
                      }"
      when 'Lead'
        params_json = "{
                        \"Street\":\"#{sobject["Street"]}\",
                        \"State\":\"#{sobject["State"]}\",
                        \"LastName\":\"#{sobject["LastName"]}\",
                        \"FirstName\":\"#{sobject["FirstName"]}\",
                        \"Email\":\"#{sobject["Email"]}\",
                        \"Description\":\"#{sobject["Description"]}\",
                        \"Country\":\"#{sobject["Country"]}\",
                        \"Company\":\"#{sobject["Company"]}\",
                        \"City\":\"#{sobject["City"]}\"
                      }"
    end

    Token::get_token.post("#{INSTANCE_URL}sobjects/#{type}/#{sobject["Id"]}?_HttpMethod=PATCH", 
                          params_json, 
                          {'Content-type' => 'application/json'})
  end

end
