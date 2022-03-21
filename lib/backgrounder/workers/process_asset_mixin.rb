# encoding: utf-8
module CarrierWave
  module Workers

    module ProcessAssetMixin
      include CarrierWave::Workers::Base

      def self.included(base)
        base.extend CarrierWave::Workers::ClassMethods
      end

      def perform(*args)
        record = super(*args)

        if record && record.send(:"#{column}").present?
          record.send(:"process_#{column}_upload=", true)
          if record.send(:"#{column}").recreate_versions! && record.respond_to?(:"#{column}_processing")
            record.update_attribute :"#{column}_processing", false
          end
        else
          when_not_ready
        end

        key = record.send(:"#{column}").versions.keys.first
        version_file = record.send(:"#{column}").send(key).file
        pp 'version file'
        pp version_file.inspect

        if version_file.blank?
          pp 'no version'
          pp 'try get original url'
          pp record.reload.send(:"#{column}").url
          record.send(:"process_#{column}_upload=", true)
          record.send(:"remote_#{column}_url=", record.reload.send(:"#{column}").url)
          record.send(:"#{column}").recreate_versions!
          pp 'maybe need save?'
        else
          pp '2nd start of worker'
          pp args
          self.class.perform_async(*args)
        end
      end

    end # ProcessAssetMixin

  end # Workers
end # Backgrounder
