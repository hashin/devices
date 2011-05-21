# TODO: refactoring
# TODO: when using the library Type, change from hash to methods
class Status
  # Find the matching status representing a specific device
  def self.find_matching_status(device_properties, statuses) 
    result = []
    statuses.each do |status|
      passed = [true]
      passed += status[:properties].collect do |status_property|
        device_property = device_properties.where(uri: status_property[:uri]).first
        #device_property = device_properties.find {|p| p.uri?(status_property[:uri]) }
        match_conditions?(status_property, device_property)
      end
      result << status if passed.inject(:&)
    end
    return result
  end

  private

    def self.match_conditions?(status_property, device_property)
      match_value?(status_property, device_property) and match_pending?(status_property, device_property)
    end

    def self.match_value?(status_property, device_property)
      status_property[:values].include?(device_property[:value]) or status_property[:values].empty?
    end

    def self.match_pending?(status_property, device_property)
      status_property[:pending] == device_property[:pending] or status_property[:pending].nil?
    end
end
