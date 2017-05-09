server "192.168.1.181", :app, :web, :db, :primary => true
set :rails_env, "staging"
set :user, 'hutbindada'
set :branch, :master
set :deploy_to, "/home/hutbindada/www/telegeam_bot"

default_run_options[:pty] = true
set :default_environment, {
  'PATH' => "/home/hutbindada/.rbenv/shims:/home/hutbindada/.rbenv/bin:$PATH"
}