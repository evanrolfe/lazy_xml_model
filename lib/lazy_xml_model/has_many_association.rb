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
            xml_element,
            options
          )
          instance_variable_set("@#{association_name}", collection_proxy)
          collection_proxy
        end

        # _attributes= Builder Method
        # NOTE: This method requires that your object follows the API defined in ActiveModel::AttributeAssignment
        define_method("#{association_name}_attributes=") do |attributes|
          collection_proxy = send(association_name)
          collection_proxy.attributes = attributes
        end
      end
    end
  end
end
