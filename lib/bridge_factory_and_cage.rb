require 'singleton'
require 'net/http'
require 'json'

module BridgeFactoryAndCage
  CageAddr = Struct.new(:host, :port)

  #
  class CagesBridge
    include Singleton

    def initialize
      @cages = [
        CageAddr.new("localhost", 23432)
      ]

      p "cages", @cages
    end

    def sample
      return @cages.sample
    end
  end


  #
  class FactoryBridge
    include Singleton

    def initialize
      @server_host = "localhost"
      @server_port = 8000

      @table = nil

      load_profiles()
    end

    # raise exception when error occured
    def load_profiles()
      # read profiles
      res = Net::HTTP.start(@server_host, @server_port) {|http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get('/api/profiles')
      }
      p res, res.code
      raise "HTTP status is not succeeded" if res.code != '200'

      begin
        profiles_arr = JSON.parse(res.body)
        @table = ProfileTable.new(profiles_arr)

      rescue => e
        p "error", e    # TODO: fix
      end
    end

    def get_profile(name, version)
      load_profiles() if @table.nil?

      return @table.get(name, version)
    end

    def foo
      p "foo"
      load_profiles
    end
  end


  class ProfilesHolder
    include Singleton

    def initialize()
      @table = nil
    end

    def load_table(profiles_arr)
      tmp_table = ProfileTable.new(profiles_arr)
      @table = tmp_table

    rescue => e
      # TODO: implement
    end

    def get(name, version)
      return @table.get(name, version)
    end
  end

  #
  private

  class ExecProfile
    def initialize(hash)
      @extention = hash['extension']    # string
      @raw_commands = hash['commands']  # []string
      @raw_envs = hash['envs']          # map[string]string
      @fixed_commands = hash['fixed_commands']          # [][]string
      @selectable_options = hash['selectable_options']  # map[string][]string
      @cpu_limit = hash['cpu_limit']        # number
      @memory_limit = hash['memory_limit']  # number
    end
    attr_reader :extention, :raw_commands, :raw_envs, :fixed_commands, :selectable_options
    attr_reader :cpu_limit, :memory_limit
  end

  class Profile
    def initialize(hash)
      @name = hash['name']
      @version = hash['version']
      @display_version = hash['display_version']
      @is_build_required = hash['is_build_required']
      @is_link_independent = hash['is_link_independent']
      @compile = hash['compile'].nil? ? nil : ExecProfile.new(hash['compile'])
      @link = hash['link'].nil? ? nil : ExecProfile.new(hash['link'])
      @exec = hash['run'].nil? ? nil : ExecProfile.new(hash['run'])     # in frontend use 'exec'
    end
    attr_reader :name, :version, :display_version
    attr_reader :is_build_required, :is_link_independent
    attr_reader :compile, :link, :exec
  end


  class ProfileTable
    def initialize(arr)
      @profiles = arr.map do |hash|
        Profile.new(hash)
      end

      @table = {}
      @profiles.each do |prof|
        @table[prof.name] = {} if @table[prof.name].nil?
        @table[prof.name][prof.version] = prof
      end
    end

    def get(name, version)
      return nil unless @table.has_key?(name)
      return nil unless @table[name].has_key?(version)

      return @table[name][version]
    end
  end
end
