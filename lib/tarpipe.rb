$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'shared-mime-info'
require 'net/http'
require 'uri'

class TarPipe
  ENDPOINT = 'rest.receptor.tarpipe.net'
  ENDPOINT_PORT = 8000
  
  attr_accessor :token

  class NoWorkflowToken < ArgumentError; end

  def initialize(token = "")
    @token = token
  end

  def upload(title = "", body = "", image = "")
    raise NoWorkflowToken, "TarPipe API requires your Workflow Token" unless @token

    post "/?key=#{@token}", { :title => title, :body => body }, { :image => image }
  end

  private
  def post(path, args, image)
    content_type, body = encode_multipart_formdata(args, image)

    headers = {
      'User-Agent' => 'TarPipe-Ruby',
      'Content-Type' => content_type
    }

    http = Net::HTTP.new(ENDPOINT, ENDPOINT_PORT)
    resp, data = http.post2(path, body, headers)

    data
  end

  def encode_multipart_formdata(fields, files, boundary = "427e4cb4ca329_133ae40413c81ef")
    r = fields.inject('') do |result, element|
      unless element.last.empty?
        result << "--" << boundary << "\r\n"
        result << "Content-Disposition: form-data; name=\"#{element.first}\"\r\n\r\n"
        result << element.last
      end

      result
    end
    
    r << files.inject('') do |result, element|
      unless element.last.empty?
        result << "\r\n--" << boundary << "\r\n"
        result << "Content-Disposition: form-data; name=\"#{element.first}\";"
        result << "filename=\"#{element.last}\"\r\n"
        result << "Content-Type: #{get_content_type(element.last)}\r\n\r\n"
        result << File.new(element.last, 'r').read
      end

      result
    end

    r << "\r\n--" << boundary << "--\r\n"

    content_type = 'multipart/form-data; boundary=%s' % boundary
    return content_type, r
  end

  def get_content_type(file)
    begin
      MIME.check(file).to_s
    rescue Exception => e
      'application/octet-stream'
    end
  end
end
