require_dependency 'scrap'
require_relative '../elasticsearch_indexed_model'

class Scrap
  def self.control_fields
    %w(advertise published)
  end
end
