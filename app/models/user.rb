# frozen_string_literal: true

class User < ApplicationRecord
  MIN_AGE = 1
  MAX_AGE = 90

  has_many :user_interests
  has_many :interests, through: :user_interests

  has_many :user_skils
  has_many :skills, through: :user_skills
end
