require_relative 'simple_worker_unit_test_base'

# bump..
class DbTests < SimpleWorkerUnitTestBase

  merge_worker 'mysql_worker', "MysqlWorker"
  merge_worker 'mysql2_worker', "Mysql2Worker"
  merge_worker 'mongo_worker', "MongoWorker"


  def test_mysql

    mysql_worker = MysqlWorker.new
    mysql_worker.config = @config
    mysql_worker.queue

    status = mysql_worker.wait_until_complete
    log status
    assert status['status'] == 'complete'
    log "log=" + mysql_worker.get_log.to_s

  end

  def test_mysql2

    mysql_worker = Mysql2Worker.new
    mysql_worker.config = @config
    mysql_worker.queue

    status = mysql_worker.wait_until_complete
    log status
    assert status['status'] == 'complete'
    log "log=" + mysql_worker.get_log.to_s

  end

  def test_mongoid

    mw = MongoWorker.new
    mw.config = @config
    mw.queue
    status = mw.wait_until_complete
    log status
    assert status['status'] == 'complete'
    log mw.get_log


  end
end
