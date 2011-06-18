require_relative 'suite_worker'

# bump asdf

class MySuiteWorker < SuiteWorker

  attr_accessor :config

  merge_gem 'hipchat-api'

  def on_complete

    log 'POSTING TO HIPCHAT!'

    client = HipChat::API.new(config['hipchat']['api_key'])
#      puts client.rooms_list
    notify_users = false
    msg = suite_results_output(:format=>'html')
    if num_failed == 0
      msg = "LBJ? - We're stylin'!<br/>" + msg
    end
    log "POSTED: " + client.rooms_message(config['hipchat']['room_name'], 'UnitTestWorker', msg, notify_users).body
  end

end
