module LazyXmlModel
  module ElementNode
    extend ActiveSupport::Concern

    included do
      def self.element_node(name)
        # Getter Method
        define_method(name) do
          name = name.to_s
          xml_doc.elements[name].text if xml_doc.elements[name].present?
        end

        # Setter Method
        define_method("#{name}=") do |value|
          name = name.to_s

          if xml_doc.elements[name].present?
            xml_doc.elements[name].text=(value)
          else
            element = REXML::Element.new(name)
            element.text=(value)
            xml_doc.elements << element
          end
        end
      end
    end
  end
end
