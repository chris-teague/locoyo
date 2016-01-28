require "locoyo/version"
require 'eventmachine'
require 'json'
require 'pry'
require 'em-http-request'
require 'zlib'
require 'fiber'

module Locoyo
  class ClientHandler < EM::Connection

    attr_accessor :port, :subdomain, :key, :address, :protocol, :connected

    def initialize(options = {})
      options = {
        port:     3000,
        address:  '127.0.0.1',
        protocol: 'http'
      }.merge(options)
      self.port      = options[:port]
      self.address   = options[:address]
      self.protocol  = options[:protocol]
      self.connected = false
      super
    end

    # Test that this is setup and working...
    def connection_completed
      start_tls
    end

    def receive_data(data)
      json = JSON.parse(data)
      send(json['type'], json['data'])
    rescue => e
      puts e
    end

    def ssl_handshake_completed
      send_data('connect')
    end

    def unbind
      @connected = false
    end

    protected

      def new_connection(data)
        self.subdomain = data['subdomain']
        self.key       = data['key']
        @connected     = true
      end

      def delegate_request(options)
        http = EventMachine::HttpRequest.new("#{protocol}://#{address}:#{port}").send(options['method'].downcase, path: options['path'], head: options['headers'], body: options['body'], query: options['query'])
        http.callback {

          encoding = http.response.encoding.name
          if encoding == 'UTF-8'
            encoded_data = Base64.encode64(Zlib::Deflate.deflate(http.response))
          else
            encoded_data = Base64.encode64(http.response)
          end

          response = {
            status:       http.response_header.status,
            content_type: http.response_header["CONTENT_TYPE"],
            body:         encoded_data,
            encoding:     encoding,
            uuid:         options['uuid']
          }
          send_data(response.to_json)
        }
      end

  end

  class Tunnel

    attr_accessor :connection, :port, :address, :protocol, :remote_address, :remote_port

    def initialize(options = {})
      options = {
        port:            3000,
        address:        '127.0.0.1',
        protocol:       'http',
        remote_address: 'client.uxspec.com',
        remote_port:     5000
      }.merge(options)

      self.port           = options[:port]
      self.address        = options[:address]
      self.protocol       = options[:protocol]
      self.remote_address = options[:remote_address]
      self.remote_port    = options[:remote_port]
      self.connection     = nil

      Thread.new { EventMachine.run }
      while not EM.reactor_running?; end
    end

    def run
      @connection = EventMachine.connect(
        @remote_address,
        @remote_port,
        ClientHandler, { port: @port, address: @address, protocol: @protocol }
      )
    end

    def get_subdomain

      # Fiber.new {
      #   fiber = Fiber.current

      #   EM.add_timer(5) { fiber.resume(nil) }
      #   EM.add_periodic_timer(0.01) do
      #     if @connection && @connection.connected
      #       puts 'OSOGHSOGNOS'
      #       puts @connection.subdomain
      #       fiber.resume(@connection.subdomain)
      #     end
      #   end
      #   Fiber.yield(fiber.transfer)
      #   # result = Fiber.yield('cocks')
      #   # puts "result: #{result}"
      #   # return result
      # }.resume

      @connection.subdomain
    end

    def stop
      EventMachine.stop
    end

  end

end
