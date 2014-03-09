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

get "/uploaded" do
  file = grid.get($id)
  return "content_type=#{file.content_type} <br>" \
  " file.metadata.inspect=#{file.metadata.inspect} <br>"\
  " file.chunk_size=#{file.chunk_size} <br>"\
  " file.file_length=#{file.file_length} <br>"\
  " file.filename=#{file.filename} <br>"\
  " <PRE> file.data=#{file.data} </PRE>"
end
 
# Handle GET-request (Show the upload form)
get "/upload" do
  haml :upload
end      
    
# Handle POST-request (Receive and save the uploaded file)
post "/upload" do 
  $id = grid.put(params['myfile'][:tempfile].read, :filename => params['myfile'][:filename])

  
  # File.open('uploads/' + params['myfile'][:filename], "w") do |f|
  #   f.write(params['myfile'][:tempfile].read)
  # end

  return "The file was successfully uploaded! id=#{$id}"
end

