require_dependency 'comment'
require_relative '../elasticsearch_indexed_model'

class Comment
  def self.control_fields
    %w()
  end
end
