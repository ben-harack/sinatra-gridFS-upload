require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('ruby-mongo-examples')

# This is the gridFS handle
grid = Grid.new(db) 

# This is a direct handle on the fs.files collection. 
# It lets us perform queries on the files that we have 
#  rather than merely storing and retrieving them.
@@files_collection = db.collection("fs.files") 

def file_download(filename)
  # This helper function is used to download files with and without extensions
  # Look in GridFS for the given filename, sorting by the uploadDate
  cursor = @@files_collection.find({"filename" => filename}, {:sort => ["uploadDate", :desc]})
  if cursor.count > 1 
    response_string = "There are #{cursor.count} files that have the name: #{filename}.<br> They are listed below along with the dates on which they were uploaded. Click any of the links to download the file.<br>"
    cursor.each do |file_item| 
      response_string = response_string + "<a href=\"#{request.base_url}/download/id/#{file_item["_id"].to_s}\">Date: #{file_item["uploadDate"].to_s} &nbsp;&nbsp; Filename: #{filename}</a><br>"
    end
  else
    # Since there is only one file, redirect so that they get the download.
    redirect "/download/id/#{cursor.first["_id"].to_s}"
  end
  response_string
end

get '/hi' do
  "Hello World"
end

get "/most_recent_upload" do
  # Get the file handle from gridfs
  file = grid.get($id)
  # Set the content type to generic
  content_type 'binary/octet-stream'  
  #Push the file at the browser
  attachment "#{file.filename}"
  response.write file.read  
end

get '/download/:filename' do |filename|
  file_download(filename)
end

# Get a file by a specific file id
get '/download/id/:file_id' do |file_id|
  file = grid.get(BSON::ObjectId("#{file_id}"))
  content_type 'binary/octet-stream'  
  #Push the file at the browser
  attachment "#{file.filename}"
  response.write file.read  
end
 
# Handle GET-request (Show the upload form)
get "/upload" do
  haml :upload
end      
    
# Handle POST-request (Receive and save the uploaded file)
post "/upload" do 
  $id = grid.put(params['myfile'][:tempfile].read, :filename => params['myfile'][:filename])
  return "The file was successfully uploaded! id=#{$id}"
end


  


