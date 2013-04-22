FactoryGirl.define do
  factory :user do
  	name "jack"
  	password "secret_pass"
  end

  factory :city do
  	name "foo"
  	min_t "foobar"
  	max_t ""
  	association :user
  end
end