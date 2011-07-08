require_relative 'suite_worker'

require 'redis'
require 'uri'

# bump..

class MySuiteWorker < SuiteWorker

  attr_accessor :config

  merge_gem 'hipchat-api'

  def on_complete

    log 'POSTING TO HIPCHAT!'

    client = HipChat::API.new(config['hipchat']['api_key'])
#      puts client.rooms_list
    notify_users = false
    do_post = true
    msg = suite_results_output(:format=>'html')
    uri = URI.parse(config['redis']['url'])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    if num_failed == 0
      # Only post every so often when nothing failed
      last_run_fails = (redis.get "last_run_fails" || 99).to_i
      skip_count = (redis.get("skip_count") || 0).to_i
      log "skip_count=#{skip_count}"
      if skip_count >= 10 || last_run_fails > 0 # post if last run had errors, but this one doesn't
        msg = "LBJ? - We're stylin'!<br/>" + msg
        redis.set "skip_count", 0
      else
        do_post = false
      end
    end
    redis.set "last_run_fails", num_failed
    if do_post
      log "POSTED: " + client.rooms_message(config['hipchat']['room_name'], 'UnitTestWorker', msg, notify_users).body
    else
      log "Not posting, no errors."
    end

  end

end
