# will run a suite of other test workers
# test
require 'json'

class TestInfo
  attr_accessor :file, :clazz, :config, :results, :num_failed

  def initialize()
    @file = file
    @clazz = clazz
    @config = config
    @results = results
    @num_failed = num_failed
  end

  def self.json_create(object)
    obj = new
    for key, value in object
      next if key == 'json_class'
      if key == 'id'
        obj.id = value
        next
      end
      obj.instance_variable_set key, value
    end
    obj
  end

  def self.from_json(json_string)
    return JSON.parse(json_string)
  end


  def as_json(options={})
    puts 'as_json called with options: ' + options.inspect
    result = {}
#    result['id'] = self.id
    result['json_class'] = self.class.name unless options && options[:exclude_json_class]
    self.instance_variables.each do |name|
#                puts name.to_s + "=" + val.inspect

      result[name] = instance_variable_get(name)

#                puts 'result[name]=' + result[name].inspect
    end
    puts 'as_json result=' + result.inspect
#            ret = result.as_json(options)
#            puts 'ret=' + ret.inspect
#            return ret
    result
  end


end

class SuiteWorker < SimpleWorker::Base

  attr_accessor :tests, :num_failed

  def initialize
    @tests = []
  end

  def add(file, clazz, config={})
    ti = TestInfo.new
    ti.file = file
    ti.clazz = clazz
    ti.config = config
    @tests << ti
  end

  def setup
    @tests.each do |t|
      self.class.merge_worker t.file, t.clazz
    end
  end

  def run
    setup
    @start_time = Time.now
    @num_failed = 0
    @failed = []
    @num_tests = 0
    @tests.each do |t|
      log "t=" + t.inspect
      test = nil
      begin
        c = Kernel.const_get(t.clazz)
        log c.inspect
        log c.superclass.inspect
        test = c.new
        test.config = t.config
#        test.queue
#        status = test.wait_until_complete
        test.run_local
        # todo: should allow a worker to have a small result so this could pull test.result which would be a json object with test results.
        t.results = test.results
        t.num_failed = test.num_failed
        @num_failed += test.num_failed
        @failed += test.failed
        @num_tests += test.num_tests

      rescue => ex
        log "TEST CLASS FAILED TO RUN: #{ex.message}"
        log ex.backtrace
        t.results = ex
      end
    end
    @end_time = Time.now

    log "\n" + suite_results_output

    on_complete


  end

  def suite_results_output(options={})
    line_break = "\n"
    if options[:format] == 'html'
      line_break = "<br/>"
    end
    s = "Suite Results:#{line_break}"
    s << "#{@num_failed} failed out of #{@num_tests} tests.#{line_break}"
    if @num_failed > 0
      @failed.each do |f|
        s << "#{f.test_class}.#{f.test_method} failed: #{f.result.message}#{line_break}"
      end
    end
    s << "Test suite duration: #{duration}ms.#{line_break}"
    s
  end

  def duration
    ((@end_time.to_f - @start_time.to_f) * 1000.0).to_i
  end

  def time_in_ms(t)
    (t.to_f * 1000.0).to_i
  end

  # callbacks
  def on_complete

  end

end
