require_relative 'element_proxy'

module LazyXmlModel
  module ElementNode
    extend ActiveSupport::Concern

    included do
      def self.element_node(element_tag)
        # Proxy Accessor Method
        define_method("#{element_tag}_proxy".to_sym) do
          element_proxy = instance_variable_get("@#{element_tag}_proxy")
          return element_proxy if element_proxy.present?

          element_proxy = LazyXmlModel::ElementProxy.new(element_tag, xml_document, xml_element)
          instance_variable_set("@#{element_tag}_proxy", element_proxy)
          element_proxy
        end

        # Getter Method
        define_method(element_tag) do
          element_proxy = send("#{element_tag}_proxy".to_sym)
          element_proxy.value
        end

        # Setter Method
        define_method("#{element_tag}=") do |value|
          element_proxy = send("#{element_tag}_proxy".to_sym)
          element_proxy.value = value
        end
      end
    end
  end
end
