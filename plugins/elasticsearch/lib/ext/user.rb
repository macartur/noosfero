require_dependency 'user'
require_relative '../elasticsearch_indexed_model'

class User
  def self.control_fields
    %w()
  end
end
