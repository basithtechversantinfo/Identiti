require 'delegate'
require "persona-statistics/all-methods"

module PersonaStatistics
  class Stats < SimpleDelegator
    include AllMethods
  end
end