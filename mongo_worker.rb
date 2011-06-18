# Sample worker that connects to MongoDB and performs some operations.

require 'simple_worker'
require 'mongoid'

class MongoWorker < SimpleWorker::Base

  attr_accessor :config

  merge 'person'

  def run
    init_mongodb

    log "saving person..."
    person = Person.new(:first_name => "Ludwig", :last_name => "Beethoven the #{rand(100)}")
    person.save!
    log person.inspect

    sleep 2

    log "querying persons..."

    persons = Person.find(:all, :conditions=>{:first_name=>"Ludwig"})
    persons.each do |p|
      log "found #{p.first_name} #{p.last_name}"
    end


  end

  # Configures settings for MongoDB. Values for mongo_host and mongo_port are passed in
  # to make the example easy to understand. Could be placed directly inline to streamline.
  def init_mongodb
    mconfig = @config['mongo']
    mongo_db_name   = mconfig["mongo_db_name"]
    mongo_host   = mconfig["mongo_host"]
    mongo_port   = mconfig["mongo_port"]
    mongo_username = mconfig['mongo_username']
    mongo_password = mconfig['mongo_password']

    Mongoid.configure do |config|
      config.database = Mongo::Connection.new(mongo_host, mongo_port).db(mongo_db_name)
      config.database.authenticate(mongo_username, mongo_password)
#      config.slaves = [
#          Mongo::Connection.new(host, 27018, :slave_ok => true).db(name)
#      ]
      config.persist_in_safe_mode = false
    end
  end

end
