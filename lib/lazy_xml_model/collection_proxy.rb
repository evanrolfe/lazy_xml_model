module LazyXmlModel
  class CollectionProxy
    include Enumerable
    extend Forwardable

    attr_reader :association_name, :xml_doc, :options

    def_delegators :collection, :each, :[], :size, :length, :empty?

    def initialize(association_name, xml_doc, options = {})
      @association_name = association_name
      @xml_doc = xml_doc
      @options = options
    end

    def <<(item)
      if collection.any?
        xml_doc.insert_after(collection.last.xml_doc, item.xml_doc)
      else
        xml_doc.elements << item.xml_doc
      end

      @collection << item
    end
    alias_method :push, :<<

    # TODO:
    def concat(item)
      raise NotImplementedError
    end

    def delete(item)
      # Delete the object thats wrapping this xml document
      item_from_collection = @collection.find { |collection_item| collection_item.xml_doc == item.xml_doc }
      @collection.delete(item_from_collection)

      # Delete from the xml document
      xml_doc.delete(item.xml_doc)
    end

    def delete_all
      @collection = []
      xml_doc.elements.to_a(association_name).each do |element|
        xml_doc.delete(element)
      end
    end
    alias_method :clear, :delete_all

    # TODO:
    def build(params = {})
      raise NotImplementedError
    end

    private

    def collection_xml_doc
      xml_doc.elements.to_a(association_name)
    end

    def collection
      @collection ||= []

      collection_xml_doc.map do |item_xml_doc|
        item_from_collection = @collection.find { |item| item.xml_doc == item_xml_doc }

        if item_from_collection.present?
          item_from_collection
        else
          item = klass.build_from_xml_doc(item_xml_doc)
          @collection << item
          item
        end
      end
    end

    def klass
      return options[:class_name].constantize if options[:class_name].present?

      association_name.camelize.constantize
    end
  end
end
