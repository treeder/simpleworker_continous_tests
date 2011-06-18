# This can be used as a base class for running tests on SimpleWorker.
# Sorta replaces test/unit kind of thing.

# todo: run tests in parallel?? way faster and takes advantage of SW.

require 'test/unit/assertions'
require 'simple_worker'

class TestResult
  attr_accessor :result, :test_class, :test_method

  def initialize()
    @result = result
    @test_class = test_class
    @test_method = test_method
  end

  def passed?
    result == true
  end

  def message
    if result.respond_to? :message
      return result.message
    end
    "NO MSG"
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

class SimpleWorkerUnitTestBase < SimpleWorker::Base

  include Test::Unit::Assertions

  attr_accessor :config
  attr_reader :results, :num_failed,
              :failed # TestResult's that failed

  def initialize
    @num_tests = 0
    @num_failed = 0
  end

  def self.starts_with?(s, s2)
    s[0, s2.length] == s2
  end

  def run
    methods = self.class.public_instance_methods
    results = {}
    @failed = []
    methods.each do |method|
      if self.class.starts_with?(method.to_s, "test_")
        log 'method = ' + method.inspect
        result = TestResult.new()
        result.test_class = self.class.name
        result.test_method = method
        results[method] = result
        begin
          r = self.send(method)
          result.result = r != false
        rescue MiniTest::Assertion => ex
          # do something different here?
          result.result = ex
          @failed << result
        rescue => ex
          result.result = ex
          @failed << result
        end
      end
    end

    @results = results

    num_failed = 0
    results.each_pair do |k, v|
      log "#{k} passed?: #{v.passed?}"
      if !v.passed?
        log "\t#{v.message}"
        num_failed += 1
      end
    end

    log "\n\n#{num_failed} failed out of #{results.size} tests."
    @num_failed = num_failed

  end

  def num_tests
    @results.size
  end

end
