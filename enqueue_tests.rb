require 'simple_worker'
require 'yaml'
require_relative 'db_tests'
require_relative 'my_suite_worker'

@config = YAML.load_file('config.yml')
p @config

SimpleWorker.configure do |config|
  config.access_key = @config["sw_access_key"]
  config.secret_key = @config["sw_secret_key"]
end

#test = DbTest.new(@config)
#test.run_local

suite_worker = MySuiteWorker.new
suite_worker.config = @config
suite_worker.add('basic_tests', 'BasicTests', @config)
suite_worker.add('db_tests', 'DbTests', @config)
suite_worker.setup

#suite_worker.schedule(:start_at=>Time.now, :run_every=>3600)

suite_worker.queue
#status = suite_worker.wait_until_complete
#p status
