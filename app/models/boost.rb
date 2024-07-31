class Boost < ApplicationRecord
  belongs_to :hilo, counter_cache: true
  belongs_to :user
end
