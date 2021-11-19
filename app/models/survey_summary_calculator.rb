class SurveySummaryCalculator

  attr_reader :submissions, :recipients

  def initialize(submissions:, recipients:)
    @submissions = submissions
    @recipients = recipients
  end

  def completion_rate
    PersonaStatistics::Stats.new([@recipients.count].map(&:to_f)).percentage_from_value(@submissions.allowed.count)
  end

  def respondents
    @submissions.allowed.count
  end

  def recipients
    @submissions.count
  end

  def average_time
    ms_to_hour_minutes(averages_array(@submissions.pluck(:total_time)))
  end

  private

  def averages_array(time_array)
    PersonaStatistics::Stats.new(time_array).mean
  end

  def ms_to_hour_minutes(time_in_ms)
    hours = time_in_ms / (1000 * 60 * 60)
    minutes = time_in_ms / (1000 * 60) % 60
    seconds = time_in_ms / (1000) % 60

    # "#{hours.to_i}:#{minutes.round(2).ceil}"
    # [hours, minutes].map do |t|
    #   t.round.to_s.rjust(2,'0')
    # end.join(':')

    { hours: hours.round.to_s.rjust(2,'0'),
      minutes: minutes.round.to_s.rjust(2,'0'),
      seconds: seconds.round.to_s.rjust(2,'0') }
  rescue
    { hours: 00,
      minutes: 00,
      seconds: 00 }
  end
end
