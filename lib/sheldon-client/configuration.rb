class SheldonClient
  module Configuration
    def host
      @host || "http://sheldon-production.ci-dev.moviepilot.com"
    end

    def host=( value )
      @host = value.chomp("/")
    end
    
    def log
      @log || false
    end
    
    def log=( value )
      @log = value
    end
  end
end
