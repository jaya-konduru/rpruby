require 'rake'
require 'pathname'
require 'tempfile'
require_relative '../rpruby'

namespace :rpruby do
  desc 'Start launch in Report Portal and print its id to $stdout (for use with attach_to_launch formatter mode)'
  task :start_launch do
    description = ENV['description'] || Rpruby::Settings.instance.description
    file_to_write_launch_id = ENV['file_for_launch_id'] || Rpruby::Settings.instance.file_with_launch_id
    file_to_write_launch_id ||= Pathname(Dir.tmpdir) + 'rp_launch_id.tmp'
    launch_id = Rpruby.start_launch(description)
    File.write(file_to_write_launch_id, launch_id)
    puts launch_id
  end

  desc 'Finish launch in Report Portal (for use with attach_to_launch formatter mode)'
  task :finish_launch do
    launch_id = ENV['launch_id'] || Rpruby::Settings.instance.launch_id
    file_with_launch_id = ENV['file_with_launch_id'] || Rpruby::Settings.instance.file_with_launch_id
    puts "Launch id isn't provided. Provide it either via RP_LAUNCH_ID or RP_FILE_WITH_LAUNCH_ID environment variables" if !launch_id && !file_with_launch_id
    puts 'Both RP_LAUNCH_ID and RP_FILE_WITH_LAUNCH_ID are provided via environment variables' if launch_id && file_with_launch_id
    Rpruby.launch_id = launch_id || File.read(file_with_launch_id)
    Rpruby.close_child_items(nil)
    Rpruby.finish_launch
  end
end
