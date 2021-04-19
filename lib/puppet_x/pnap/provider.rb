require 'puppet'
require 'bmc-sdk'
require 'json'

module PuppetX
  module PNAP
    # Pnap Provider
    class Provider < Puppet::Provider
      def self.read_only(*methods)
        methods.each do |method|
          define_method("#{method}=") do |_|
            Puppet.warning "#{method} property is read-only once #{resource.type} created."
          end
        end
      end

      def self.init_bmc_client(client_id, client_secret)
        client_hash = {
          client_id: client_id,
          client_secret: client_secret,
        }
        Bmc::Sdk.new_client(client_hash)
      end

      def init_bmc_client
        self.class.init_bmc_client
      end

      def self.load_bmc_client
        Bmc::Sdk.load_client
      rescue => e
        raise Puppet::Error, "Could not load BMC Client: #{e}"
      end

      def load_bmc_client
        self.class.load_bmc_client
      end

      def self.parse_error_message(error, hide_validation_errors = false)
        return error.message unless defined?(error.response)

        error = Bmc::Sdk::ErrorMessage.new(
          error.response.parsed['message'],
          error.response.parsed['validationErrors'],
        )

        if !hide_validation_errors && !error.validationErrors.nil?
          "#{error.message} - Validation Errors: #{error.validationErrors}"
        else
          error.message
        end
      end

      def parse_error_message(error, hide_validation_errors = true)
        self.class.parse_error_message(error, hide_validation_errors)
      end

      def clean_hash(hash)
        hash.each do |key, value|
          if value.nil?
            hash.delete(key)
          end
        end
      end
    end
  end
end
