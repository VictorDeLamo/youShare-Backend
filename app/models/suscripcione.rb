class Suscripcione < ApplicationRecord
  belongs_to :user
  belongs_to :magazine
end
