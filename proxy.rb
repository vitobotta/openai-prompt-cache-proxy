require 'sinatra'
require 'net/http'
require 'json'
require 'uri'

UPSTREAM_BASE_URL = ENV.fetch("UPSTREAM_BASE_URL", "http://host.docker.internal:3456")

class CompletionsProxy < Sinatra::Base
  configure do
    set :server, :puma
    set :logging, true
    set :port, 5678
    set :bind, "0.0.0.0"
  end

  def forward_request(request)
    uri = URI.parse("#{UPSTREAM_BASE_URL}#{request.path}")
    http = Net::HTTP.new(uri.host, uri.port)

    upstream_request = case request.request_method
    when 'POST'
      Net::HTTP::Post.new(uri.path)
    when 'GET'
      Net::HTTP::Get.new(uri.path)
    else
      halt 405, 'Method not allowed'
    end

    request.env.each do |key, value|
      if key.start_with?('HTTP_')
        header_key = key[5..-1].split('_').map(&:capitalize).join('-')
        upstream_request[header_key] = value
      end
    end

    upstream_request['Content-Type'] = 'application/json'

    if request.body.size > 0
      body = JSON.parse(request.body.read)
      body['cache_prompt'] = true
      upstream_request.body = body.to_json
    end

    [http, upstream_request]
  end

  def stream_response(response)
    response.read_body do |chunk|
      yield chunk
    end
  end

  def handle_completion_request(request)
    content_type 'application/json'

    http, upstream_request = forward_request(request)

    request_body = JSON.parse(upstream_request.body)
    is_streaming = request_body['stream'] == true

    if is_streaming
      headers 'Content-Type' => 'text/event-stream'
      headers 'Cache-Control' => 'no-cache'
      headers 'Connection' => 'keep-alive'

      stream do |out|
        http.request(upstream_request) do |response|
          stream_response(response) do |chunk|
            out << chunk
          end
        end
      end
    else
      response = http.request(upstream_request)
      status response.code
      response.body
    end
  end

  post '/v1/chat/completions' do
    self.handle_completion_request(request)
  end

  post '/v1/completions' do
    self.handle_completion_request(request)
  end

  error do |e|
    status 500
    { error: e.message }.to_json
  end
end

if __FILE__ == $0
  CompletionsProxy.run!
end
