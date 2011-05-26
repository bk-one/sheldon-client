class SheldonClient
  module Configuration
    def host
      @host || "http://sheldon-production.ci-dev.moviepilot.com:2312"
    end

    def host=( value )
      @host = value.chomp("/")
    end
    
    def log?
      @log || false
    end
    
    def log=( value )
      @log = value
    end
    
    def log_file=( value )
      @logfile = value
    end
    
    def log_file
      @logfile
    end
  end
end
