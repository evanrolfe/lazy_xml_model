module LazyXmlModel
  class ObjectProxy
    attr_reader :association_name, :xml_doc, :options

    def initialize(association_name, xml_doc, options = {})
      @association_name = association_name
      @xml_doc = xml_doc
      @options = options
    end

    # Getter Method
    def object
      return unless xml_doc.elements[association_name].present?

      @object ||= begin
        object = klass.build_from_xml_doc(
          xml_doc.elements[association_name]
        )
        object.parent_xml_doc = xml_doc
        object
      end
      @object
    end

    # Setter Method
    def object=(new_object)
      # TODO:
      raise StandardError, 'You cannot replace an object yet sorry!' if @object.present?

      @object = new_object

      xml_doc.elements << @object.xml_doc
      @object.parent_xml_doc = xml_doc
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
