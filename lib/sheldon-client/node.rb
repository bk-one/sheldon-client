class SheldonClient
  class Node
    attr_accessor :id, :type, :payload

    def initialize( hash )
      self.id      = hash['id']
      self.type    = hash['type']
      self.payload = hash['payload']
    end

    def to_s
      "#<Sheldon::Node #{id} (#{type}/#{name})>"
    end

    def to_i
      self.id
    end

    def name
      payload['name'] || payload['title']
    end
  end
end
