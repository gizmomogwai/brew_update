require 'json'
require 'io/console'

task :outdated do
  sh "brew outdated"
end

def update(name)
  sh "brew unlink #{name}"
  sh "brew install #{name}"
end

AUTO_UPDATES = "#{ENV['HOME']}/.brew_auto_updates"

task :update do
  auto_updates = []
  begin
    auto_updates = JSON.parse(File.read(AUTO_UPDATES))
  rescue
    puts "no #{AUTO_UPDATES} file found"
  end
  begin
    JSON.parse(`brew outdated --json=v1`).each do |package|
      name = package['name']
    if auto_updates.include?(name)
      answer = 'Y'
    else
      puts "Update #{name}? y(es)/a(lways)/n(o)/q(uit)"
      answer = STDIN.getch
    end
    if answer == 'a'
      auto_updates << name
      answer = 'y'
    end
    if answer == 'q'
      break
    end
    if answer == 'y'
      update(name)
    end
    end
    sh "brew cleanup"
  ensure
    File.open(AUTO_UPDATES, "w") do |io|
      io.write(auto_updates.to_json + "\n")
    end
  end
end
