$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'shared-mime-info'
require 'net/http'
require 'uri'

# TarPipe is a bridge to the tarpipe.com's REST API
#
# Author:: Ruben Fonseca (mailto:root@cpan.org)
# Copyright:: Copyright (c) 2008 Ruben Fonseca
# License:: GPLv3 (see License.txt)

# This class encapsulates the TarPipe funcionality
class TarPipe
  # If we want to change the endpoint
  attr_accessor :endpoint, :endpoint_port
  
  # This acessor allows the user to select the worflow key anytime
  attr_accessor :key

  # Error thrown when the user doesn't specify a workflow key
  class NoWorkflowKey < ArgumentError; end

  # The key is optional
  def initialize(key = "")
    @key = key
    @endpoint = 'rest.receptor.tarpipe.net'
    @endpoint_port = 8000
  end

  # Makes a call to a workflow. All the parameters are optional:
  #  :title a title
  #  :body  a body
  #  :image a fill path for an existing file
  def upload(params = {})
    @key = params[:key] if params[:key]
    raise NoWorkflowKey, "TarPipe API requires your Workflow Key" unless @key

    # Filter arguments
    args = [:title, :body].inject({}) do |res, arg|
      res[arg] = params[arg] if params[arg]
      res
    end

    # Filter files
    files = [:image].inject({}) do |res, arg|
      res[arg] = params[arg] if params[arg]
      res
    end

    post "/?key=#{@key}", args, files
  end

  private
  # Encapsulates the upload operation. Encodes the multipart post, sets headers and
  # uploads the request. Returns the result from the server.
  def post(path, args, files)
    content_type, body = encode_multipart_formdata(args, files)

    headers = {
      'User-Agent' => 'TarPipe-Ruby',
      'Content-Type' => content_type
    }

    http = Net::HTTP.new(@endpoint, @endpoint_port)
    resp, data = http.post2(path, body, headers)

    case resp
    when Net::HTTPSuccess
      true
    else
      false
    end
  end

  # Constructs a multipart/form-data body from the arguments and files passed
  # as arguments.
  def encode_multipart_formdata(fields, files, boundary = "427e4cb4ca329_133ae40413c81ef")
    r = fields.inject('') do |result, element|
      result << "--" << boundary << "\r\n"
      result << "Content-Disposition: form-data; name=\"#{element.first}\"\r\n\r\n"
      result << element.last

      result
    end
    
    r << files.inject('') do |result, element|
      result << "\r\n--" << boundary << "\r\n"
      result << "Content-Disposition: form-data; name=\"#{element.first}\";"
      result << "filename=\"#{element.last}\"\r\n"
      result << "Content-Type: #{get_content_type(element.last)}\r\n\r\n"
      result << File.new(element.last, 'r').read

      result
    end

    r << "\r\n--" << boundary << "--\r\n"

    content_type = 'multipart/form-data; boundary=%s' % boundary
    return content_type, r
  end

  # Tries to guess the mime type of a file. Defaults to application/octet-stream.
  def get_content_type(file)
    begin
      MIME.check(file).to_s
    rescue Exception => e
      'application/octet-stream'
    end
  end
end
