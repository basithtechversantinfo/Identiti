module PersonaStatistics
  module CentralTendency
    def sum(identity = 0, &block)
      if block_given?
        PersonaStatistics::Stats.new(map(&block)).sum(identity)
      else
        inject(:+) || identity
      end
    end

    def mode_multi(&block)
      array = map(&block).to_a
      count = []
      output = []
      array.compact!
      unique = array.uniq
      j=0

      unique.each do |i|
        count[j] = array.count(i)
        j+=1
      end
      k=0
      count.each do |i|
        output[k] = unique[k] if i == count.max
        k+=1
      end

      return output.compact
    end

    def mean
      return if length < 1
      sum / length.to_f
    end

    def median
      return if length < 1
      sorted = self.sort

      if length % 2 == 0
        (sorted[(length/2) -1 ] + sorted[length / 2]) / 2.0
      else
        sorted[length / 2]
      end
    end

    def mode
      return if length < 1
      frequency_distribution = inject(Hash.new(0)) { |hash, value| hash[value] += 1; hash }
      top_2 = frequency_distribution.sort { |a,b| b[1] <=> a[1] } .take(2)
      if top_2.length == 1
        top_2.first.first # Only one value in distribution, so it's the mode.
      elsif top_2.first.last == top_2.last.last
        nil # Equal frequency, no mode.
      else
        top_2.first.first # Most frequent is mode.
      end
    end

    def percentage_from_value(value)
      return if length < 1
      (value / sum.to_f * 100).ceil
    end

    def personality_percentage_from_value(value)
      return if length < 1
      (value / sum.to_f * 100).round(1)
    end
  end
end