# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( survey_build.js survey_build.css )
Rails.application.config.assets.precompile += %w( nested_hidden_input_sorting.js show_more_less_content.js )
Rails.application.config.assets.precompile += %w( survey_preview.css )
Rails.application.config.assets.precompile += %w( frontend.js frontend.css )
Rails.application.config.assets.precompile += %w( application.js application.css )
Rails.application.config.assets.precompile += %w( country_state_cities.js )
Rails.application.config.assets.precompile += %w( active-accordian.js )
Rails.application.config.assets.precompile += %w( main.css )
Rails.application.config.assets.precompile += %w( pdf.css )
Rails.application.config.assets.precompile += %w( amcharts/core.js amcharts/charts.js amcharts/animated.js )
Rails.application.config.assets.precompile += %w( Chart.min chartjs/chartjs-plugin-datalabels )
Rails.application.config.assets.precompile += %w( echart/echarts-en echart/echarts-wordcloud )

Rails.application.config.assets.precompile += %w( devise.css )

Rails.application.config.assets.precompile += %w( save_selected_tab.js )

Rails.application.config.assets.precompile += %w( mailer.scss pdf_bootstrap.css application.scss frontend.scss bootstrap.css survey_build/css/fontawesome.css survey_build/css/all.min.css survey_build/css/style.css survey_build/css/responsive.css toster/utoast.css survey_build/multi-select/sumoselect.css survey_build/multi-select/sumoselect.min.css survey_build/main.css group_modal.css frontend/main-style.css frontend/main-responsive.css frontend/inner.css results-preview.scss results-modal.scss persona-summary.scss persona-customized.scss persona-template1.scss  dashboard.scss chartjs/chartjs-plugin-datalabels.js echart/echarts-en.js echart/echarts-wordcloud.js Chart.min.js)
