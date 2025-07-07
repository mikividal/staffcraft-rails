module Cacheable
  extend ActiveSupport::Concern

  class_methods do
    def cache_key_for(id, updated_at = nil)
      if updated_at
        "#{model_name.cache_key}/#{id}-#{updated_at.to_i}"
      else
        "#{model_name.cache_key}/#{id}"
      end
    end
  end

  def cache_key
    if new_record?
      "#{model_name.cache_key}/new"
    else
      timestamp = updated_at || Time.current
      "#{model_name.cache_key}/#{id}-#{timestamp.to_i}"
    end
  end
end
