class Test < Thor
  desc 'spec', 'Run all the specs'
  def spec
    system('rspec spec') || exit($?.exitstatus)
  end
end
