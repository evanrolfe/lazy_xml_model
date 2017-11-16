require_relative 'element_proxy'

module LazyXmlModel
  module ElementNode
    extend ActiveSupport::Concern

    included do
      def self.element_node(element_name)
        # Proxy Accessor Method
        define_method("#{element_name}_proxy".to_sym) do
          element_proxy = instance_variable_get("@#{element_name}_proxy")
          return element_proxy if element_proxy.present?

          element_proxy = LazyXmlModel::ElementProxy.new(element_name, xml_document, xml_element)
          instance_variable_set("@#{element_name}_proxy", element_proxy)
          element_proxy
        end

        # Getter Method
        define_method(element_name) do
          element_proxy = send("#{element_name}_proxy".to_sym)
          element_proxy.element_value
        end

        # Setter Method
        define_method("#{element_name}=") do |value|
          element_proxy = send("#{element_name}_proxy".to_sym)
          element_proxy.element_value = value
        end
      end
    end
  end
end
