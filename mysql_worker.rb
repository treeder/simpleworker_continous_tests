require 'mysql'
require 'active_record'

class MysqlWorker < SimpleWorker::Base

  attr_accessor :config

  def connect(config)
    ActiveRecord::Base.establish_connection(config['mysql'].merge!(:adapter=>'mysql'))
  end

  merge "photo"

  def run
   
    connect(config)

    photo = Photo.create!(:name=>"hi", :url=>"http://www.whatever.com")
    photo = Photo.first
    log "first photo=" + photo.inspect

  end

end
