require File.dirname(__FILE__) + '/spec_helper.rb'

require 'tempfile'

describe TarPipe, " new instance" do
  SAMPLE_TOKEN = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'

  it "should create a new instance without key" do
    t = TarPipe.new
    t.should_not be_nil
    t.key.should be_empty
  end

  it "should create an instance with a key" do
    t = TarPipe.new(SAMPLE_TOKEN)
    t.should_not be_nil
    t.key.should == SAMPLE_TOKEN
  end
end

describe TarPipe, " endpoints" do
  it "should have an endpoint and endpoint_port acessor" do
    t = TarPipe.new
    t.endpoint.should == 'rest.receptor.tarpipe.net'
    t.endpoint_port.should == 8000
  end
end

describe TarPipe, " #upload" do
  GOOD_TOKEN = '0181f285f1cac168d358b8993fd75e3a'
  BAD_TOKEN  = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

  before(:each) do
    @t = TarPipe.new(GOOD_TOKEN)
  end

  it "should throw NoWorkflowKey if there is no key" do
    @t.key = nil

    proc do
      @t.upload(:title => 'title', :body => 'body')
    end.should raise_error(TarPipe::NoWorkflowKey)
  end

  it "should upload a title and body" do
    r = @t.upload :title => 'title', :body => 'body'

    r.should be_true
  end

  it "should be capable to upload an image" do
    # Prepare a temporary file to upload
    tf = Tempfile.new('image')
    10.times { tf.puts "garbage " }
    tf.flush

    # Upload it
    r = @t.upload(:title => 'title', :body => 'body', :image => tf.path)

    r.should be_true
  end

  it "should give an error if we use an invalid workflow key" do
    @t.key = BAD_TOKEN

    r = @t.upload :title => 'title', :body => 'body'
    r.should be_false
  end
end
