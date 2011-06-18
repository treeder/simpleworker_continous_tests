require 'simple_worker'

# bump adsf
class OneLineWorker < SimpleWorker::Base

  def run
    log Time.now
    log "hello"
    log Time.now
  end
end
