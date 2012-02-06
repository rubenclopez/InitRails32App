#!/usr/bin/env ruby


#RUBY_VERSION  = `ruby -v`[/1.9.*?\s/]
RAILS_VERSION = `gem list rails`[/rails.*3.2.*/]
RVM_LOCATION  = `echo $GEM_HOME`[/.*.rvm.*/]
RSPEC_VERSION = `gem list rspec-rails`[/.*2.8.*/]


puts RUBY_VERSION
puts RAILS_VERSION
puts RVM_LOCATION


puts ARGV

def check_requirements
  errors = []
  print "Checking Presence of Ruby 1.9... "
  puts RUBY_VERSION ? "[FOUND] #{RUBY_VERSION}" : "#{ puts '[FAILED]' ; errors << 'Ruby not found' }"
  print "Checking Presence of Rails 3.*... "
  puts RAILS_VERSION ? "[FOUND] #{RAILS_VERSION}" : "#{ puts '[FAILED]' ; errors << 'Rails not found'; nil }"
  
  unless errors.empty?
    puts "#{errors.join('\n')}"
    puts "Please fix the errors above and re-run this script."
    exit
  end

  puts "You might want to consider using RVM to organize your Ruby/Rails environments." unless RVM_LOCATION

end

def check_options
  unless ARGV[0]
    puts "Please specify as a parameter the name of the rails application"
    exit;
  end
end

def create_rails_apps
  puts "creating rails app named #{ARGV[0]}... "
  if File.directory?(ARGV[0])
    puts "[ALREADY CREATED]"
  else
    puts `rails new "#{ARGV[0]}"`
  end
end

def install_rspec
  print "Changing to application dir... "
  Dir.chdir("#{ARGV[0]}")
  puts "[DONE]"

  puts "Checking for RSPEC... "
  if RSPEC_VERSION
    puts "[AlREADY INSTALLED]"
  else
    puts `gem install rspec-rails`
  end

end

def configure_gemfile
  gemfile = File.open("Gemfile").read
  print "Checking for :test group"
  if gemfile[/group :test/]
    # TODO: Actually do this automagically
    puts "Please add: gem \"rspec-rails\" to your :test group"
  else
    puts ""
    print "Adding :test group to Gemfile... "
    gemfile += "\ngroup :test do\n  gem \"rspec-rails\"\n  gem \"capybara\"\nend\n"
    puts "[DONE]"
  end


  puts "Checking for :development group"
  if gemfile[/group :development/]
    # TODO: Actually do this automagically
    puts "Please add: gem \"rspec-rails\" to your :development group"
  else
    print "Adding :development group to Gemfile... "
    gemfile += "\ngroup :development do\n  gem \"rspec-rails\"\n  gem \"capybara\"\nend\n"
    puts "[DONE]"
  end
  print "Writing Gemfile... "
  File.open("Gemfile", "w") { |f| f.puts gemfile }
  puts "[DONE]"

end




def running_bundler
  print "Running Bundler... "
  puts `bundle install`
  puts "[DONE]"
end


def running_generators
  puts "Running RSPEC generator..."
  puts `rails generate rspec:install`
end






check_requirements
check_options
create_rails_apps
install_rspec
configure_gemfile
running_bundler
running_generators

