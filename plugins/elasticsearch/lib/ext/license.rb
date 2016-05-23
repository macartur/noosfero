require_dependency 'license.rb'
require_relative '../elasticsearch_indexed_model'

class License
  def self.control_fields
    %w()
  end
end
