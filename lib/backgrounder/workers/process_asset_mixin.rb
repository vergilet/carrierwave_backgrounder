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


        if args[:versions_process] && args[:remote_image_url]
          record.send(:"process_#{column}_upload=", true)
          record.send(:"remote_#{column}_url=", args[:remote_image_url])
          record.send(:"#{column}").recreate_versions!
        else
          remote_image_url = record.reload.send(:"#{column}").url
          self.class.perform_async(*args.merge(versions_process: true, remote_image_url: remote_image_url))
        end
      end

    end # ProcessAssetMixin

  end # Workers
end # Backgrounder
