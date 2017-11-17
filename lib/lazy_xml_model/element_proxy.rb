module LazyXmlModel
  class ElementProxy
    attr_reader :element_tag, :xml_document, :xml_parent_element

    def initialize(element_tag, xml_document, xml_parent_element)
      @element_tag = element_tag
      @xml_document = xml_document
      @xml_parent_element = xml_parent_element
    end

    # Getter Method
    def value
      if xml_element.present?
        xml_element.children.first.content
      end
    end

    # Setter Method
    def value=(value)
      if xml_element.present?
        xml_element.children.first.content = value
      else
        xml_element = Nokogiri::XML::Element.new(element_tag.to_s, xml_document)
        xml_element.content = value
        xml_parent_element.add_child(xml_element)
      end
    end

    private

    def xml_element
      xml_parent_element.elements.find { |element| element.name == element_tag.to_s }
    end
  end
end
