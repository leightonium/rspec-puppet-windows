if ENV['COVERAGE'] == 'yes'
  require 'coveralls'
  Coveralls.wear!
end

require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'modules')
  c.manifest_dir = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'manifests')
  c.environmentpath = File.join(Dir.pwd, 'spec')

  c.before :each do
    Puppet[:autosign] = true # Change autosign from being posix path, which breaks Puppet when we're pretending to be on Windows
   
    f = self.respond_to?(:facts) ? facts : {} # Work even if you don't specify facts
    Thread.current[:windows?] = lambda { f[:kernel] == "windows" } # Automatically detect whether we're pretending to run on Windows
  
    c.after(:suite) do
      RSpec::Puppet::Coverage.report!
    end
  end
end

module Puppet
  module Util
    module Platform
      def self.windows?
        # This is where Puppet normally looks for the target OS.
        # It normally returns the *current* OS (i.e., not Windows,
        # if you're not running the specs on Windows)
        !!Thread.current[:windows?].call
      end
    end
  end
end
