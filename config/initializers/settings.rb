# Load settings configuration
Settings.add_source!("#{SpreeAdyen::Engine.root}/config/settings.yml")
Settings.add_source!("#{SpreeAdyen::Engine.root}/config/settings/#{Rails.env}.yml")
Settings.add_source!("#{SpreeAdyen::Engine.root}/config/settings.local.yml")

Settings.reload!