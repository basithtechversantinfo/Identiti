module ApplicationHelper
  require 'net/http'
  require 'json'

  include SurveysHelper
  include QuestionOptionsHelper

  $DASHBOARD_NAV_CLASSES = "dashboard-nav"
  $PERSONAS_NAV_CLASSES = "personas-nav"
  $SURVEYS_NAV_CLASSES = "surveys-nav"
  $GROUPS_NAV_CLASSES = "groups-nav groups-surveys-nav"
  $REPORTS_NAV_CLASSES = "reports-nav reports-surveys-nav"
  $LISTS_NAV_CLASSES = "lists-nav"

  def get_image_by_submission(submission)
    if submission.gender_image_slug.present?
      "#{submission.gender_image_slug}.png"
    else
      get_gender =
          if submission.data_json.to_s.match("Male").present?
            "male"
          elsif submission.data_json.to_s.match("Female").present?
            "female"
          elsif submission.data_json.to_s.match("Men").present?
            "male"
          elsif submission.data_json.to_s.match("Women").present?
            "female"
          elsif submission.recipient.gender.present?
            submission.recipient.gender.downcase
          else
            "male"
          end

      "gender/#{get_gender}-#{rand(1..99)}.png"
    end
  end

  def display_summary_name(name)
    get_gender =
        if name.to_s.match("Male").present?
          "male-name"
        elsif name.to_s.match("Female").present?
          "female-name"
        elsif name.to_s.match("Men").present?
          "male-name"
        elsif name.to_s.match("Women").present?
          "female-name"
        else
          "male-name"
        end
    get_gender
  end

  def display_summary_image(name)
    get_gender =
        if name.to_s.match("Male").present?
          "male-image"
        elsif name.to_s.match("Female").present?
          "female-image"
        elsif name.to_s.match("Men").present?
          "male-image"
        elsif name.to_s.match("Women").present?
          "female-image"
        else
          "neutral-image"
        end
    get_gender
  end

  def gender_validator(name)
    if $boolean == false
      if name.to_s.match("Male").present?
        $boolean = true
      elsif name.to_s.match("Female").present?
        $boolean = true
      elsif name.to_s.match("Men").present?
        $boolean = true
      elsif name.to_s.match("Women").present?
        $boolean = true
      else
        $boolean = nil
      end
    end
  end

  def random_user_me_female
    begin
      url = "https://randomuser.me/api/?inc=gender,name,nat,picture&gender=female&nat=us,ca,dk,fr,gb"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)["results"].first["picture"]["large"]
    rescue
      {}
    end
  end

  def random_user_me_male
    begin
      url = "https://randomuser.me/api/?inc=gender,name,nat,picture&gender=male&nat=us,ca,dk,fr,gb"
      uri = URI(url)
      response = Net::HTTP.get(uri)
      JSON.parse(response)["results"].first["picture"]["large"]
    rescue
      {}
    end
  end

  def female_image(index)
    "https://randomuser.me/api/portraits/women/#{index}.jpg"
  end

  def male_image(index)
    "https://randomuser.me/api/portraits/men/#{index}.jpg"
  end

  def charts_backgrounds_array
    [
        'rgb(255, 99, 132)',
        'rgb(255, 159, 64)',
        'rgb(255, 205, 86)',
        'rgb(75, 192, 192)',
        'rgb(54, 162, 235)',
        'rgb(153, 102, 255)',
        '#009788',
        '#9D1BB2',
        '#FFED18',
        '#FFC200',
        '#FF9900',
        '#5F7D8C',
    ]
  end

  def color_options
    [
        # ['Red', 'rgb(255, 99, 132)'],
        ['Green', '#26a69a'],
        ['Orange', 'rgb(255, 159, 64)'],
        ['Yellow', 'rgb(255, 205, 86)'],
        ['Blue', 'rgb(54, 162, 235)'],
        ['Purple', 'rgb(153, 102, 255)'],
        ['Grey', 'grey'],
    ]
  end

  def str_to_url(str)
    Permalink.generate(str)
  end

  def creator_name(created_by_id)
    Account.find_by_id(created_by_id).your_name
  rescue
    current_account.your_name
  end

  def survey_days_left(from, to)
    if to.present?
      if from.to_time.to_i > to.to_time.to_i
        acc = 'groups.' + 'finished' 
        t "#{acc}"
      else
        TimeDifference.between(from, to).in_days.ceil
      end
    else
      'N/A'
    end
  end

  def country_list
    data = JSON.parse(File.read('vendor/country_states_cities_json_objects/countries_states_cities.json'))
    countries = data.map {|k| [k["name"], k["iso2"] ] }
    countries
  end

  def industry_list
    [["Accounting\n", 0],
     ["Airlines/Aviation\n", 1],
     ["Alternative Dispute Resolution\n", 2],
     ["Alternative Medicine\n", 3],
     ["Animation\n", 4],
     ["Apparel & Fashion\n", 5],
     ["Architecture & Planning\n", 6],
     ["Arts & Crafts\n", 7],
     ["Automotive\n", 8],
     ["Aviation & Aerospace\n", 9],
     ["Banking\n", 10],
     ["Biotechnology\n", 11],
     ["Broadcast Media\n", 12],
     ["Building Materials\n", 13],
     ["Business Supplies & Equipment\n", 14],
     ["Capital Markets\n", 15],
     ["Chemicals\n", 16],
     ["Civic & Social Organization\n", 17],
     ["Civil Engineering\n", 18],
     ["Commercial Real Estate\n", 19],
     ["Computer & Network Security\n", 20],
     ["Computer Games\n", 21],
     ["Computer Hardware\n", 22],
     ["Computer Networking\n", 23],
     ["Computer Software\n", 24],
     ["Construction\n", 25],
     ["Consumer Electronics\n", 26],
     ["Consumer Goods\n", 27],
     ["Consumer Services\n", 28],
     ["Cosmetics\n", 29],
     ["Dairy\n", 30],
     ["Defense & Space\n", 31],
     ["Design\n", 32],
     ["Education Management\n", 33],
     ["E-learning\n", 34],
     ["Electrical & Electronic Manufacturing\n", 35],
     ["Entertainment\n", 36],
     ["Environmental Services\n", 37],
     ["Events Services\n", 38],
     ["Executive Office\n", 39],
     ["Facilities Services\n", 40],
     ["Farming\n", 41],
     ["Financial Services\n", 42],
     ["Fine Art\n", 43],
     ["Fishery\n", 44],
     ["Food & Beverages\n", 45],
     ["Food Production\n", 46],
     ["Fundraising\n", 47],
     ["Furniture\n", 48],
     ["Gambling & Casinos\n", 49],
     ["Glass, Ceramics & Concrete\n", 50],
     ["Government Administration\n", 51],
     ["Government Relations\n", 52],
     ["Graphic Design\n", 53],
     ["Health, Wellness & Fitness\n", 54],
     ["Higher Education\n", 55],
     ["Hospital & Health Care\n", 56],
     ["Hospitality\n", 57],
     ["Human Resources\n", 58],
     ["Import & Export\n", 59],
     ["Individual & Family Services\n", 60],
     ["Industrial Automation\n", 61],
     ["Information Services\n", 62],
     ["Information Technology & Services\n", 63],
     ["Insurance\n", 64],
     ["International Affairs\n", 65],
     ["International Trade & Development\n", 66],
     ["Internet\n", 67],
     ["Investment Banking/Venture\n", 68],
     ["Investment Management\n", 69],
     ["Judiciary\n", 70],
     ["Law Enforcement\n", 71],
     ["Law Practice\n", 72],
     ["Legal Services\n", 73],
     ["Legislative Office\n", 74],
     ["Leisure & Travel\n", 75],
     ["Libraries\n", 76],
     ["Logistics & Supply Chain\n", 77],
     ["Luxury Goods & Jewelry\n", 78],
     ["Machinery\n", 79],
     ["Management Consulting\n", 80],
     ["Maritime\n", 81],
     ["Marketing & Advertising\n", 82],
     ["Market Research\n", 83],
     ["Mechanical or Industrial Engineering\n", 84],
     ["Media Production\n", 85],
     ["Medical Device\n", 86],
     ["Medical Practice\n", 87],
     ["Mental Health Care\n", 88],
     ["Military\n", 89],
     ["Mining & Metals\n", 90],
     ["Motion Pictures & Film\n", 91],
     ["Museums & Institutions\n", 92],
     ["Music\n", 93],
     ["Nanotechnology\n", 94],
     ["Newspapers\n", 95],
     ["Nonprofit Organization Management\n", 96],
     ["Oil & Energy\n", 97],
     ["Online Publishing\n", 98],
     ["Outsourcing/Offshoring\n", 99],
     ["Package/Freight Delivery\n", 100],
     ["Packaging & Containers\n", 101],
     ["Paper & Forest Products\n", 102],
     ["Performing Arts\n", 103],
     ["Pharmaceuticals\n", 104],
     ["Philanthropy\n", 105],
     ["Photography\n", 106],
     ["Plastics\n", 107],
     ["Political Organization\n", 108],
     ["Primary/Secondary Education\n", 109],
     ["Printing\n", 110],
     ["Professional Training\n", 111],
     ["Program Development\n", 112],
     ["Public Policy\n", 113],
     ["Public Relations\n", 114],
     ["Public Safety\n", 115],
     ["Publishing\n", 116],
     ["Railroad Manufacture\n", 117],
     ["Ranching\n", 118],
     ["Real Estate\n", 119],
     ["Recreational\n", 120],
     ["Facilities & Services\n", 121],
     ["Religious Institutions\n", 122],
     ["Renewables & Environment\n", 123],
     ["Research\n", 124],
     ["Restaurants\n", 125],
     ["Retail\n", 126],
     ["Security & Investigations\n", 127],
     ["Semiconductors\n", 128],
     ["Shipbuilding\n", 129],
     ["Sporting Goods\n", 130],
     ["Sports\n", 131],
     ["Staffing & Recruiting\n", 132],
     ["Supermarkets\n", 133],
     ["Telecommunications\n", 134],
     ["Textiles\n", 135],
     ["Think Tanks\n", 136],
     ["Tobacco\n", 137],
     ["Translation & Localization\n", 138],
     ["Transportation/Trucking/Railroad\n", 139],
     ["Utilities\n", 140],
     ["Venture Capital\n", 141],
     ["Veterinary\n", 142],
     ["Warehousing\n", 143],
     ["Wholesale\n", 144],
     ["Wine & Spirits\n", 145],
     ["Wireless\n", 146],
     ["Writing & Editing", 147]]
  end

  def role_root_path
    if account_signed_in? and current_account.admin?
      admin_path
    else
      root_path
    end
  end

  def role_root_url
    if account_signed_in? and current_account.admin?
      admin_url
    else
      root_url
    end
  end

  def invitation_role_decider(user)
    u = Account.find_by_email(user.email)
    if user.active == 0 || user.active == "pending"
      u_active = "pending"
    else
      u_active = "active"
    end
    if user.allowed_to_log_in == true
      if !u.present? and (u_active == 'active')
        "#{t 'account_settings.pending'}"
      else
        acc = 'account_settings.' + u_active
        "#{t acc}"
      end
    else
      "#{t 'account_settings.disable'}"
    end
  end

  def invitation_role_index_decider(user)
    u = Account.find_by_email(user.email)
    if user.active == 0 || user.active == "pending"
      u_active = "pending"
    else
      u_active = "active"
    end
    if user.allowed_to_log_in == true
      if !u.present? and (u_active == 'active')
        "#{t 'account_settings.pending'}"
      else
        acc = 'account_settings.' + u_active
        "#{t acc}"
      end
    else
      "#{t 'account_settings.disabled'}"
    end
  end

  def user_role_for_locale(user)
    if user.role == 0 || user.role == "admin"
      u_role = "admin"
    elsif user.role == 1 || user.role == "creator"
      u_role = "creator"
    else
      u_role = "analyzer"
    end
    acc = 'account_settings.' + u_role
    "#{t acc}"
  end

  def user_role_for_dropdown_locale role
    acc = 'account_settings.' + role
    "#{t acc}"   
  end

  def chart_options(chart_type)
    if chart_type == "Bar Chart (Vertical)"
      chart_types_locale "bar_chart_v" 
    elsif chart_type == "Bar Chart (Horizontal)"
      chart_types_locale "bar_chart_h"
    elsif chart_type == "Radar Chart"
      chart_types_locale "radar_chart"
    elsif chart_type == "Pie Chart"
      chart_types_locale "pie_chart"
    elsif chart_type == "Polar Area"
      chart_types_locale "polar_area_chart"
    elsif chart_type == "NPS Chart"
      chart_types_locale "nps_chart"
    elsif chart_type == "Wordcloud Chart"
      chart_types_locale "wordcloud_chart"
    end
  end

  def chart_types_locale(chart_type)
    acc = 'surveys.' + chart_type
    "#{t acc}"
  end

  def q_options q_type
    if q_type == "Multiple Choices (Single Select)"
      q_types_locale "multiple_choice_single" 
    elsif q_type == "Multiple Choices (Multi Select)"
      q_types_locale "multiple_choice_multiple"
    elsif q_type == "Drop-down Selector (Single Select)"
      q_types_locale "drop_down_selector_single"
    elsif q_type == "Drop-down Selector (Multi Select)"
      q_types_locale "drop_down_selector_multiple"
    elsif q_type == "Rating Scale"
      q_types_locale "rating_scale"
    elsif q_type == "Comment Box"
      q_types_locale "comment_box"
    elsif q_type == "Number Field"
      q_types_locale "number_field"
    elsif q_type == "Star Ratings"
      q_types_locale "star_ratings"
    elsif q_type == "Scores"
      q_types_locale "scores"
    elsif q_type == "Range Slider"
      q_types_locale "range_slider"
    elsif q_type == "Geographic Location"
      q_types_locale "geographic_location.geographic_location"
    elsif q_type == "Date"
      q_types_locale "date"
    elsif q_type == "Visual Choices"
      q_types_locale "visual_choices"
    elsif q_type == "Screener"
      q_types_locale "screening"
    end
  end

  def q_types_locale q_type
    acc = 'surveys.' + q_type
    "#{t acc}"
  end

  def geo_options(geo)
    if geo == "Country"
      geo_locale "country" 
    elsif geo == "Country-States"
      geo_locale "country_states"
    elsif geo == "Country-States-Cities"
      geo_locale "country_states_cities"
    end
  end

  def geo_locale geo
    acc = 'surveys.' + geo
    "#{t acc}"
  end
  
  def specify_options(specify)
    if specify == "Yes"
      specify_locale "yess" 
    elsif specify == "No"
      specify_locale "noo"
    end
  end

  def specify_locale specify
    acc = 'surveys.' + specify
    "#{t acc}"
  end

  def template_options template
    if template == 'Template 1'
      template_locale 'template_1'
    elsif template == 'Template 2'
      template_locale 'template_2'   
    end
  end

  def template_locale template
     acc = 'surveys.' + template
     "#{t acc}"    
  end

  def set_container(controller, action)
    if controller == 'surveys'
      ''
    elsif controller == 'surveys/steps'
      ''
    elsif controller == 'surveys'
      ''
    elsif controller == 'survey'
      ''
    elsif controller == 'admin/template_themes/steps'
      ''
    elsif controller == 'admin/template_themes' and action == 'index'
      'container'
    elsif controller == 'admin/template_themes'
      ''
    else
      'container'
    end
  end

  def ellipsisize(string)
    return string if string.length < 30
    string[0, 18] + "..." + string[-16, 16]
  end

end
