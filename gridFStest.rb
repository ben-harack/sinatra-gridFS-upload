require 'rubygems'
require 'sinatra'
require 'haml'
require 'mongo'

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT

puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('ruby-mongo-examples')

grid = Grid.new(db)

get '/hi' do
  "Hello World"
end

get "/most_recent_upload" do
  # Get the file handle from gridfs
  file = grid.get($id)
  # Set the content type to generic
  content_type 'application/octet-stream'  
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


  


