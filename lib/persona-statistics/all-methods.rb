require 'persona-statistics/central-tendency'
require 'persona-statistics/dispersion'
require 'persona-statistics/spread'
require 'persona-statistics/shape'

module PersonaStatistics
  module AllMethods
    include CentralTendency
    include Dispersion
    include Shape
    include Spread
  end
end