require 'active_support'
require 'active_support/inflector'
require 'active_model'
require 'rexml/document'
require 'lazy_xml_model/version'
require 'lazy_xml_model/attribute_node'
require 'lazy_xml_model/element_node'
require 'lazy_xml_model/has_one_association'
require 'lazy_xml_model/has_many_association'
require 'nokogiri'

module LazyXmlModel
  extend ActiveSupport::Concern

  included do
    include AttributeNode
    include HasManyAssociation
    include HasOneAssociation
    include ElementNode

    attr_writer :xml_document, :xml_parent_element, :xml_element
    class_attribute :tag

    #
    # Class Methods
    #
    def self.parse(xml_string)
      object = self.new
      object.xml_document = Nokogiri::XML::Document.parse(xml_string, &:noblanks)
      object
    end
  end

  #
  # Instance Methods
  #
  def xml_document
    @xml_document ||= Nokogiri::XML::Document.parse("<#{root_tag}/>", &:noblanks)
  end

  def xml_parent_element
    @xml_parent_element
  end

  def xml_element
    @xml_element ||= xml_document.root
  end

  def to_xml
    # TODO: Make this work for non-root objects
    xml_document.to_xml(indent: 2, encoding: 'UTF-8')
  end

  def delete
    xml_element.remove
  end

  private

  def root_tag
    self.tag || self.class.name.demodulize.downcase
  end
end

