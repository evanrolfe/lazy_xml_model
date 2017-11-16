module LazyXmlModel
  module ElementNode
    extend ActiveSupport::Concern

    included do
      def self.element_node(name)
        # Getter Method
        define_method(name) do
          name = name.to_s
          element = xml_element.elements.find { |element| element.name == name }

          if element.present?
            element.children.first.content
          end
        end

        # Setter Method
        define_method("#{name}=") do |value|
          name = name.to_s
          element = xml_element.elements.find { |element| element.name == name }

          if element.present?
            element.children.first.content = value
          else
            element = Nokogiri::XML::Element.new(name.to_s, xml_document)
            element.content = value
            xml_element.add_child(element)
          end
        end
      end
    end
  end
end
