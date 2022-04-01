# frozen_string_literal: true

FactoryBot.define do
  FactoryBot.define do
    factory :merchant do
      name { Faker::Lorem.word }
    end
  end
end
