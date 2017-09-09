require 'rspec/expectations'

RSpec::Matchers.define :have_log do |expected|
  match do |ct|
    ct.logs.include?(expected)
  end
  failure_message do |ct|
    "#{ct.logs}\ndoes not include '#{expected}'"
  end
  failure_message_when_negated do |ct|
    "#{ct.logs}\ndoes include '#{expected}'"
  end
end
