module LazyXmlModel
  module AttributeNode
    extend ActiveSupport::Concern

    included do
      def self.attribute_node(name)
        # Getter Method
        define_method(name) do
          xml_element.attributes[name.to_s].value
        end

        # Setter Method
        define_method("#{name}=") do |value|
          xml_element.set_attribute(name.to_s, value)
        end
      end
    end
  end
end
