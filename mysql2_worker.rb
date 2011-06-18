# this one uses the mysql2 gem as it has separate issues from mysql gem. One is that it doesn't work with rails 3.0.x!

require 'mysql2'
require 'active_record'

class Mysql2Worker < SimpleWorker::Base

  attr_accessor :config

  def connect(config)
    ActiveRecord::Base.establish_connection(config['mysql'].merge!(:adapter=>'mysql2'))
  end

  merge "photo"

  def run

    connect(config)

    photo = Photo.create!(:name=>"hi", :url=>"http://www.whatever.com")
    photo = Photo.first
    log "first photo=" + photo.inspect

  end

end
