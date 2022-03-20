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

        x = record && record && record.send(:"#{column}").present?
        pp 'before'
        pp record.inspect
        pp record.send(:"#{column}").present?
        
        
        if x
          pp 'in'
          record.send(:"process_#{column}_upload=", true)
          pp 'zzz'
          z = record.send(:"#{column}").recreate_versions! && record.respond_to?(:"#{column}_processing")
          pp record.respond_to?(:"#{column}_processing")
          pp 'V'
          if record.send(:"#{column}").recreate_versions! && record.respond_to?(:"#{column}_processing")
            pp "good"
            pp "My args: #{args.inspect}"
            record.update_attribute :"#{column}_processing", false
          end
        else
          pp "not ready"
          pp "My args: #{args.inspect}"
          when_not_ready
        end
      end

    end # ProcessAssetMixin

  end # Workers
end # Backgrounder
