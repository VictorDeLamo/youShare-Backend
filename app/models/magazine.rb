class Magazine < ApplicationRecord
    validates :name, length: { in: 0..25 }, presence: true
    validates :title, length: { in: 0..50 }, presence: true
    validates :description, length: { in: 0..10000 }
    validates :rules, length: { in: 0..10000 }
    has_many :hilos, dependent: :destroy
    has_many :suscripciones, dependent: :destroy
    has_many :users, through: :suscripciones
    belongs_to :user
end
