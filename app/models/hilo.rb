class Hilo < ApplicationRecord
  #validates :title, length: { minimum: 4 }
  #validates :content, length: { in: 4..280 }
  self.inheritance_column = :hilo_type
  belongs_to :magazine
  belongs_to :user
  has_many :boosts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reactions, dependent: :destroy
  # Asumiendo que is_link es un atributo persistente o virtual

  validates :title, length: { maximum: 255 }, presence: true
  validates :content, length: { maximum: 35000 }



end
