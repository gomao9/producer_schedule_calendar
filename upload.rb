require 'dropbox'
require 'dotenv'
require 'imas/producer_schedule'
require 'tmpdir'

Dotenv.load
ACCESS_TYPE = :dropbox
MONTHS = '../months.yml'
def client
  @client ||= Dropbox::Client.new(ENV['DROPBOX_ACCESS_TOKEN'])
end

def upload(path, file, **opt)
  client.upload(path, file, opt) # => Dropbox::FileMetadata
end

def generate_calendar(dir)
  c = Imas::ProducerSchedule::Client.new
  c.output_cal(dir)
end

def rename(out_dir)
  `mv #{out_dir}/schedule.ics           #{out_dir}/producer_schedule.ics`
  `mv #{out_dir}/schedule_irregular.ics #{out_dir}/producer_schedule_irregular.ics`
  `mv #{out_dir}/schedule_regular.ics   #{out_dir}/producer_schedule_regular.ics`
end

def generate_and_upload
  Dir.mktmpdir(nil, File.expand_path('..', __FILE__)) do |out_dir|
    generate_calendar(out_dir)
    rename(out_dir)

    Dir.glob("#{out_dir}/*.ics") do |name|
      open(name) do |file|
        upload_name = File.join('/public', File.basename(name))
        upload(upload_name, file, mode: :overwrite)
      end
    end
  end
end

generate_and_upload
