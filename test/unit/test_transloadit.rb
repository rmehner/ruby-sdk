require 'test_helper'

describe Transloadit do
  before do
    @key    = 'a'
    @secret = 'b'
  end
  
  it 'must allow initialization' do
    t = Transloadit.new(:key => @key, :secret => @secret)
    t.must_be_kind_of Transloadit
  end
  
  it 'must not be initialized with no arguments' do
    lambda { Transloadit.new }.must_raise ArgumentError
  end
  
  it 'must require a key' do
    lambda { Transloadit.new(:secret => @secret) }.must_raise ArgumentError
  end
  
  it 'must not require a secret' do
    t = Transloadit.new(:key => @key)
    t.must_be_kind_of Transloadit
  end
  
  describe 'when initialized' do
    before do
      @transloadit = Transloadit.new(
        :key    => @key,
        :secret => @secret
      )
    end
    
    it 'must allow access to the key' do
      @transloadit.key.must_equal @key
    end
    
    it 'must allow access to the secret' do
      @transloadit.secret.must_equal @secret
    end
    
    it 'must create steps' do
      step = @transloadit.step('/image/resize', :width => 320)

      step.must_be_kind_of Transloadit::Step
      step.robot.  must_equal '/image/resize'
      step.options.must_equal :width => 320
    end
    
    it 'must create named steps' do
      step = @transloadit.step('/image/resize', 'resize', :width => 320)
      
      step.must_be_kind_of Transloadit::Step
      step.robot.  must_equal '/image/resize'
      step.name.   must_equal 'resize'
      step.options.must_equal :width => 320
    end
    
    it 'must create assemblies' do                     
      step     = @transloadit.step('')
      assembly = @transloadit.assembly :steps => step
      
      assembly.must_be_kind_of Transloadit::Assembly
      assembly.steps.must_equal step.to_hash
    end
    
    it 'must create assemblies with multiple steps' do
      steps = [
        @transloadit.step(''),
        @transloadit.step(''),
      ]
      
      assembly = @transloadit.assembly :steps => steps
      assembly.steps.must_equal steps.inject({}) {|h,s| h.merge s }
    end
    
    it 'must inspect like a hash' do
      @transloadit.inspect.must_equal @transloadit.to_hash.inspect
    end
    
    it 'must produce Transloadit-compatible hash output' do
      @transloadit.to_hash[:key]    .must_equal @key
      @transloadit.to_hash[:expires].
        must_match %r{\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}\+00:00}
    end
    
    it 'must produce Transloadit-compatible JSON output' do
      @transloadit.to_json.must_equal @transloadit.to_hash.to_json
    end
  end
  
  describe 'with no secret' do
    before do
      @transloadit = Transloadit.new(:key => @key)
    end
    
    it 'must not include a secret in its hash output' do
      @transloadit.to_hash.keys.wont_include :secret
    end
    
    it 'must not include a secret in its JSON output' do
      @transloadit.to_json.must_equal @transloadit.to_hash.to_json
    end
  end
end
