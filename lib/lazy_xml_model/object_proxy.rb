module LazyXmlModel
  class ObjectProxy
    attr_reader :association_name, :xml_document, :xml_parent_element, :options

    def initialize(association_name, xml_document, xml_parent_element, options = {})
      @association_name = association_name
      @xml_document = xml_document
      @xml_parent_element = xml_parent_element
      @options = options
    end

    # Getter Method
    def object
      element = xml_parent_element.elements.find { |element| element.name == association_name }
      return unless element.present?

      @object ||= begin
        new_object = klass.new
        new_object.xml_parent_element = xml_parent_element
        new_object.xml_element = element
        new_object
      end
    end

    # Setter Method
    def object=(new_object)
      @object.delete if @object.present?

      @object = new_object

      xml_parent_element.add_child(
        new_object.xml_element
      )
      new_object.xml_parent_element = xml_parent_element
    end

    # Builder Method
    def build_object(params = {})
      new_object =
        begin
          klass.new(params)
        # Incase the class does not include ActiveModel::AttributeAssignment
        rescue ArgumentError
          klass.new
        end

      self.object = new_object
    end

    def attributes=(attributes)
      if object.present?
        object.assign_attributes(attributes) # Update the object
      else
        build_object(attributes) # Build the object
      end
    end

    private

    def klass
      options[:class_name].constantize
    end
  end
end
