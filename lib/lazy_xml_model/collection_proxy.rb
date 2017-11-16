module LazyXmlModel
  class CollectionProxy
    include Enumerable
    extend Forwardable

    attr_reader :association_name, :xml_element, :options

    def_delegators :collection, :each, :[], :size, :length, :empty?

    def initialize(association_name, xml_element, options = {})
      @association_name = association_name
      @xml_element = xml_element
      @options = options
    end

    def <<(item)
      item.xml_document = nil
      item.xml_parent_element = xml_element

      if collection.any?
        collection.last.xml_element.add_next_sibling(item.xml_element)
      else
        xml_element.add_child(item.xml_element)
      end

      @collection << item
    end
    alias_method :push, :<<

    # TODO:
    def concat(item)
      raise NotImplementedError
    end

    def delete(item)
      # Delete the object thats wrapping this xml element
      @collection.delete(item)

      # Delete from the xml document
      item.xml_element.remove
    end

    def delete_all
      @collection = []
      xml_elements.each(&:remove)
    end
    alias_method :clear, :delete_all

    def build(params = {})
      new_object =
        begin
          klass.new(params)
        # Incase the class does not include ActiveModel::AttributeAssignment
        rescue ArgumentError
          klass.new
        end

      self << new_object
    end

    def attributes=(attributes)
      attributes.each do |i, object_params|
        i = i.to_i

        if self[i].present?
          if [true, 1, '1'].include?(object_params[:_destroy])
            delete(self[i]) # Delete the object
          else
            self[i].assign_attributes(object_params) # Update the object
          end
        else
          build(object_params) # Build the object
        end
      end
    end

    private

    def xml_elements
      xml_element.elements.select { |element| element.name == association_name }
    end

    def collection
      @collection ||= []

      xml_elements.map do |element|
        item_from_collection = @collection.find { |item| item.xml_element == element }

        if item_from_collection.present?
          item_from_collection
        else
          item = begin
            new_item = klass.new
            new_item.xml_parent_element = xml_element
            new_item.xml_element = element
            new_item
          end
          @collection << item
          item
        end
      end
    end

    def klass
      return ArgumentError, 'You must specify :class_name!' if options[:class_name].nil?
      options[:class_name].constantize
    end
  end
end
