require 'simple_worker'

# bump adsf
class OneLineWorker < SimpleWorker::Base
  attr_accessor :sleep_time

  def run
    log Time.now
    log "hello"
    sleep sleep_time||0
    log Time.now
  end
end
