require 'capistrano/ext/multistage'

set :keep_releases, 5
set :application, "Hutbindada Bot"
set :repository,  "git@gitlab.projectwebby.com:tim/telegrambot.git"
set :scm, :git
set :branch, :master
set :use_sudo, false
set :default_stage, "staging"

after "deploy:build", "deploy:run_bot"

namespace :deploy do
  task :build do
  end
  task :run_bot do
    run "cd #{release_path} && RAILS_ENV=staging bundle exec ruby bot.rb"
  end
end
