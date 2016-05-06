#!/usr/bin/env ruby

require 'aws-sdk'

module AWSUtils

    BASE_DIR = "#{ENV['_BIAB_ROOT']}/share/aws/"

    JSON_CONFIG_FILE = JSON.parse(File.read("#{BASE_DIR}/config.json"))
    JSON_KEYS_REGISTER = JSON.parse(File.read("#{BASE_DIR}/configs/keys.register"))

    LOCATIONS = JSON_CONFIG_FILE['locations']


    # Returns a Aws::EC2::Client
    # with the credentials configured
    def AWSUtils.get_ec2_client(region)

        user_credentials = {}

        # If file exists then let ec2 client use the credentials file
        # located in $USER_HOME/.aws/credentials. This is very usefull
        # for jenkins because there is install process involved
        if File.exist?(BASE_DIR + "/credentials")

            user_credentials = File.open("#{BASE_DIR}/credentials") do |file|
                properties = {}

                file.read.each_line do |line|
                    line.strip!
                    if line[0] != ?# and line[0] != ?=
                        i = line.index('=')
                        if i
                            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
                        else
                            properties[line] = ''
                        end
                    end
                end

                properties
            end
        end

        options = {
            :region => region
        }

        if user_credentials
            options[:access_key_id] = user_credentials['aws_access_key_id']
            options[:secret_access_key] = user_credentials['aws_secret_access_key']
        end

        # noinspection RubyArgCount
        Aws::EC2::Client.new(options)

    end


    # Returns instance information
    # in json format
    def AWSUtils.get_instance_info(instance_name)

        instance_info = nil

        LOCATIONS.each { |location|

            region = location['region']

            # noinspection RubyArgCount
            resp = get_ec2_client(region).describe_instances(
                {
                    filters: [
                        {
                            name: 'tag:Name',
                            values: [instance_name],
                        },
                    ],
                })

            resp.reservations.each do |res|
                res.instances.each do |inst|

                    tag = ''
                    inst[:tags].each { |t| tag += "#{t.value} " }

                    instance_info = {
                        :name => instance_name,
                        :host => "#{inst[:public_ip_address]}",
                        :user => 'ec2-user',
                        :privateKey => "#{ENV['_BIAB_ROOT']}/share/#{JSON_KEYS_REGISTER[inst[:key_name]]}",
                        :tag => "#{tag} AWS",
                        :instanceId => "#{inst[:instance_id]}",
                        :region => region,
                        :state => "#{inst[:state].name}"
                    }
                end
            end
        }

        instance_info

    end

    def AWSUtils.print_instance_info(instance_name)
        instance_info = get_instance_info(instance_name)

        if instance_info
            puts JSON.pretty_generate(instance_info)
        end
    end

end