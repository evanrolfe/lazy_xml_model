require_relative 'object_proxy'

module LazyXmlModel
  module HasOneAssociation
    extend ActiveSupport::Concern

    included do
      def self.has_one(association_name, options)
        association_name = association_name.to_s

        # Proxy Accessor Method
        define_method("#{association_name}_proxy".to_sym) do
          object_proxy = instance_variable_get("@#{association_name}_proxy")
          return object_proxy if object_proxy.present?

          object_proxy = LazyXmlModel::ObjectProxy.new(association_name, xml_doc, options)
          instance_variable_set("@#{association_name}_proxy", object_proxy)
          object_proxy
        end

        # Getter Method
        define_method(association_name) do
          object_proxy = send("#{association_name}_proxy".to_sym)
          object_proxy.object
        end

        # Setter Method
        define_method("#{association_name}=".to_sym) do |object|
          object_proxy = send("#{association_name}_proxy".to_sym)
          object_proxy.object = object
        end

        # Builder Method
        define_method("build_#{association_name}") do |params = {}|
          object_proxy = send("#{association_name}_proxy".to_sym)
          object_proxy.build_object(params)
        end

        # _attributes= Builder Method
        # NOTE: This method requires that your object follows the API defined in ActiveModel::AttributeAssignment
        define_method("#{association_name}_attributes=") do |attributes|
          object_proxy = send("#{association_name}_proxy".to_sym)
          object_proxy.attributes = attributes
        end
      end
    end
  end
end
