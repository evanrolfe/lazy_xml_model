require_relative 'collection_proxy'

module LazyXmlModel
  module HasManyAssociation
    extend ActiveSupport::Concern

    included do
      def self.has_many(association_name, options = {})
        # Accessor Method
        define_method(association_name) do
          collection_proxy = instance_variable_get("@#{association_name}")
          return collection_proxy if collection_proxy.present?

          collection_proxy = LazyXmlModel::CollectionProxy.new(
            association_name.to_s.singularize.gsub('_',''),
            xml_doc,
            options
          )
          instance_variable_set("@#{association_name}", collection_proxy)
          collection_proxy
        end
      end
    end
  end
end
