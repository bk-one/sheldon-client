class SheldonClient
  module Configuration
    def host
      @host || "http://sheldon-production.ci-dev.moviepilot.com"
      #@host || 'http://sheldon.labs.mvp.to:2311'
    end

    def host=( value )
      @host = value.chomp("/")
    end
  end
end
