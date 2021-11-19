class PersonaIdentifier

  def initialize(record)
    @record = record
  end

  def gender
    gender =
        if @record.to_s.match("Male").present?
          "male"
        elsif @record.to_s.match("Female").present?
          "female"
        elsif @record.to_s.match("Men").present?
          "male"
        elsif @record.to_s.match("Women").present?
          "female"
        else
          "neutral-gender"
        end

    gender
  end

  def gender_image_slug
    # respondent image decider
    if gender == "neutral-gender"
      "gender/#{gender}"
    else
      "gender/#{gender}-#{rand(1..99)}"
    end
  end

  def gender_name
    # respondent name decider
    if gender == "female"
      Faker::Name.unique.female_first_name + ' ' + Faker::Name.last_name
    else
      Faker::Name.unique.male_first_name + ' ' + Faker::Name.last_name
    end
  end
end