FactoryBot.define do
  FactoryBot.define do
    factory :item do
      name { Faker::Lorem.word}
      description {Faker::Lorem.sentence}
      unit_price {Faker::Number.decimal(l_digits: 2)}
      merchant_id {Faker::Number.number(digits: 3)}
    end
  end
end
