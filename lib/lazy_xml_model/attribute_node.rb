module LazyXmlModel
  module AttributeNode
    extend ActiveSupport::Concern

    included do
      def self.attribute_node(name)
        # Getter Method
        define_method(name) do
          xml_doc.attributes[name.to_s]
        end

        # Setter Method
        define_method("#{name}=") do |value|
          xml_doc.attributes[name.to_s] = value
        end
      end
    end
  end
end
