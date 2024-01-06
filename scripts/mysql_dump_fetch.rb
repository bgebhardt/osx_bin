#!/usr/bin/env ruby
# == Synopsis
#
# mysql_dump_fetch.rb: gets the produiction dump of the mysql db and outputs a
# file 'mysqldump.backup.sql.gz' in the local directory
# requires the aws-s3 gem (http://amazon.rubyforge.org/)
#
# == Usage
#
# mysql_dump_fetch.rb [-h|--help]
#
# -h, --help: show help
#

require 'rubygems'
require 'getoptlong'
require 'rdoc/usage'
require 'aws/s3'

# Get command line options
opts = GetoptLong.new(
  [ '--help',  '-h', GetoptLong::NO_ARGUMENT]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
  end
end

AWS::S3::Base.establish_connection!(:access_key_id => '1V77E1FFQVWZXJ128B82', :secret_access_key => 'KomfqWqzw9MSdfffHY4d9VS4OMH7pgqguveamTLi')

class Riddler < AWS::S3::S3Object
  set_current_bucket_to 'mysql_backup_riddler'
end

db_dump = Riddler.value 'mysqldump.backup.sql.gz'

File.open('mysqldump.backup.sql.gz','wb') { |f| f.syswrite db_dump }
exit 0
