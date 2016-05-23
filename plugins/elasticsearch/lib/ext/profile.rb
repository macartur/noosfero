require_dependency 'profile'
require_relative '../elasticsearch_indexed_model'

class Profile
  def self.control_fields
    %w( visible public_profile )
  end
end
