def run_install_template(path)
  system "#{RbConfig.ruby} ./bin/rails app:template LOCATION=#{File.expand_path("../install/#{path}.rb", __dir__)}"
end

namespace :turbo_train do
  desc "Install Turbo::Train into the app"
  task :install do
    run_install_template 'create_initializer'

    if Rails.root.join("config/importmap.rb").exist?
      Rake::Task["turbo_train:install:importmap"].invoke
    elsif Rails.root.join("package.json").exist?
      Rake::Task["turbo_train:install:node"].invoke
    else
      puts "We can't detect neither (package.json) nor importmap-rails (config/importmap.rb) 🙁"
      puts "Please refer to https://github.com/Uscreen-video/turbo-train/blob/main/README.md#installation for manual installation instructions."
    end
  end

  namespace :install do
    desc "Install Turbo::Train into the app with asset pipeline"
    task :importmap do
      run_install_template "install_importmap"
    end

    desc "Install Turbo::Train into the app with webpacker"
    task :node do
      run_install_template "install_node"
    end
  end
end
