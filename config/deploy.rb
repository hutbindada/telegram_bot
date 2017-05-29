require 'mina/git'
require 'mina/bundler'
require 'mina/rbenv'
require 'mina/multistage'

set :repository,
    'git@gitlab.projectwebby.com:tim/telegrambot.git'
set :app_path, fetch(:current_path)
set :shared_files, [
  'config/secrets.yml',
  'config/config.yml',
  '.rbenv-vars'
]
set :stages, %w(staging production)
set :default_stage, 'staging'
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp')

task :environment do
  invoke :'rbenv:load'
end

task :setup do
end

desc 'Deploys the current version to the server.'
task deploy: :environment do
  deploy do
    fetch(:rails_env)
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'deploy:cleanup'
  end
end
