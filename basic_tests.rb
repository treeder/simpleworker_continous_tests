require_relative 'simple_worker_unit_test_base'
require 'active_support/core_ext'

# bumpasdfasdf
class BasicTests < SimpleWorkerUnitTestBase

  attr_accessor :config
  merge_worker 'one_line_worker', 'OneLineWorker'

  def test_for_truth
    assert true
  end

  # for trying failures
#  def test_fail
#    assert false, "dang"
#  end
#  def test_exception
#    raise "dang exception"
#  end

  def test_queue
    worker = OneLineWorker.new
    worker.queue
    status = worker.wait_until_complete
    log status
    assert status['status'] == 'complete'
    log worker.get_log

  end

  def test_schedule
    tr = OneLineWorker.new
    start_date = 15.seconds.from_now
    response_hash = tr.schedule(:start_at => start_date, :end_at=>start_date + 1.minutes, :priority=>2)
    puts 'response_hash=' + response_hash.inspect
    assert response_hash, "Couldn't get response"
    if response_hash
      assert response_hash["schedule_id"], "Wrong response code"
      status = wait_for_task(:schedule_id=>response_hash["schedule_id"])
      assert status, "Scheduled task wasn't executed"
      assert status["status"] == "complete", "wrong task status"
      tasks = SimpleWorker.service.get_schedules.collect { |schedule| schedule["schedule_id"] }
      assert tasks.include?(response_hash["schedule_id"]), "Response should contains schedule id"
    end
  end

  def test_cancel_schedule
    tr = OneLineWorker.new
    start_date = Time.now.tomorrow
    response_hash = tr.schedule(:start_at => start_date, :end_at=>start_date + 1.minutes, :priority=>1)
    puts 'response_hash=' + response_hash.inspect
    assert response_hash, "Couldn't get response"
    sleep 1
    if response_hash
      schedule_id=response_hash["schedule_id"]
      assert schedule_id, "Wrong response code"
      response_hash = SimpleWorker.service.cancel_schedule(schedule_id)
      sleep 2
      assert (response_hash["schedule_id"]==tr.schedule_id), ("Wrong response,should contains id, #{response_hash.inspect}")
      assert (tr.status["status"]=='cancelled'), "Wrong status,current status #{tr.status}"
    end
  end


  def test_timeout
    worker = OneLineWorker.new
    worker.sleep_time=40
    worker.queue(:timeout=>20)
    status = wait_for_task(worker)
    assert status["duration"] < 30000, "Timeout doesn't work"
  end


  def wait_for_task(params={})
    tries = 0
    status = nil
    sleep 1
    while  tries < 60
      status = status_for(params)
      puts 'status=' + status.inspect + ' for ' + (params.inspect)
      if status["status"] == "complete" || status["status"] == "error"|| status["status"] == "killed"
        break
      end
      sleep 2
    end
    status
  end

  def status_for(ob)
    if ob.is_a?(Hash)
      ob[:schedule_id] ? SimpleWorker.service.schedule_status(ob[:schedule_id]) : SimpleWorker.service.status(ob[:task_id])
    else
      ob.status
    end
  end

end
