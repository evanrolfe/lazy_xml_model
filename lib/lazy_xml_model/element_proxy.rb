module LazyXmlModel
  class ElementProxy
    attr_reader :element_name, :xml_document, :xml_element

    def initialize(element_name, xml_document, xml_element)
      @element_name = element_name
      @xml_document = xml_document
      @xml_element = xml_element
    end

    # Getter Method
    def element_value
      if element.present?
        element.children.first.content
      end
    end

    # Setter Method
    def element_value=(value)
      if element.present?
        element.children.first.content = value
      else
        element = Nokogiri::XML::Element.new(element_name.to_s, xml_document)
        element.content = value
        xml_element.add_child(element)
      end
    end

    private

    def element
      xml_element.elements.find { |element| element.name == element_name.to_s }
    end
  end
end
