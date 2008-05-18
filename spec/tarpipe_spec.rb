require File.dirname(__FILE__) + '/spec_helper.rb'

require 'tempfile'

describe TarPipe, " new instance" do
  SAMPLE_TOKEN = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'

  it "should create a new instance without token" do
    t = TarPipe.new
    t.should_not be_nil
    t.token.should be_empty
  end

  it "should create an instance with a token" do
    t = TarPipe.new(SAMPLE_TOKEN)
    t.should_not be_nil
    t.token.should == SAMPLE_TOKEN
  end
end

describe TarPipe, " #upload" do
  GOOD_TOKEN = '0181f285f1cac168d358b8993fd75e3a'
  BAD_TOKEN  = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

  before(:each) do
    @t = TarPipe.new(GOOD_TOKEN)
  end

  it "should throw NoWorkflowToken if there is no token" do
    @t.token = nil

    proc do
      @t.upload('title', 'body')
    end.should raise_error(TarPipe::NoWorkflowToken)
  end

  it "should upload a title and body" do
    r = @t.upload('title', 'body')

    r.should_not be_nil
    r.should =~ %r{ok!} # XXX: this is not documented on the API
  end

  it "should be capable to upload an image" do
    # Prepare a temporary file to upload
    tf = Tempfile.new('image')
    10.times { tf.puts "garbage " }
    tf.flush

    # Upload it
    r = @t.upload('title', 'body', tf.path)

    r.should_not be_nil
    r.should =~ %r{ok!} # XXX: this is not documented on the API
  end

  it "should give an error if we use an invalid workflow token" do
    @t.token = BAD_TOKEN

    r = @t.upload 'title', 'body'
    
    r.should_not be_nil
    r.should =~ %r{Not found.} # XXX: this is not documented on the API
  end
end
