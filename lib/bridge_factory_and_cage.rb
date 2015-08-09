require 'singleton'
require 'net/http'
require 'json'
require 'torigoya_kit'

module BridgeFactoryAndCage
  CageAddr = Struct.new(:host, :port)

  #
  class CagesBridge
    include Singleton

    def initialize
      # TODO: fix
      if Rails.env.production?
        @cages = [
          CageAddr.new(ENV["REMOTE_CAGE1_HOST"], ENV["REMOTE_CAGE1_PORT"])
        ]
      else
        @cages = [
          CageAddr.new("localhost", 23456)
        ]
      end
    end

    def make_client
      addr = self.sample
      return TorigoyaKit::Client.new(addr.host, addr.port)
    end

    def update_all_nodes
      succeeded = true

      @cages.each do |addr|
        begin
          c = TorigoyaKit::Client.new(addr.host, addr.port)
          resp = c.update_packages()
          raise "" if resp != 0

        rescue => e
          Rails.logger.log "Failed to update packages of node #{addr.host}:#{addr.port}"
          succeeded &&= false
        end
      end

      return succeeded
    end

    def sample
      return @cages.sample
    end
  end


  #
  class FactoryBridge
    include Singleton

    def initialize
      # TODO: fix
      if Rails.env.production?
        @server_host = "factory.pg.yutopp.net"
        @server_port = 8000
      else
        @server_host = "localhost"
        @server_port = 8000
      end

      @table = nil
    end

    # raise exception when error occured
    def load_profiles()
      # read profiles
      puts "Loading configs from #{@server_host}:#{@server_port}"   # Rails.logger.info

      res = Net::HTTP.start(@server_host, @server_port) {|http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get('/api/profiles')
      }
      raise "HTTP status is not succeeded" if res.code != '200'

      profiles_arr = JSON.parse(res.body)
      @table = ProfileTable.new(profiles_arr)
    end

    def get_profile(name, version)
      load_profiles() if @table.nil?

      return @table.get(name, version)
    end

    def get_profiles
      load_profiles() if @table.nil?

      return @table.profiles
    end
  end


  #
  private
  class ProfileTable
    def initialize(arr)
      @profiles = arr.map {|hash| ProcGardenLib::Profile.new(hash)}

      @table = {}
      @profiles.each do |prof|
        @table[prof.name] = {} unless @table.has_key?(prof.name)
        @table[prof.name][prof.version] = prof
      end
    end
    attr_reader :profiles

    def get(name, version)
      return nil unless @table.has_key?(name)
      return nil unless @table[name].has_key?(version)

      return @table[name][version]
    end
  end
end
