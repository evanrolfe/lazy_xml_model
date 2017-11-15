require 'active_support'
require 'active_model'
require 'rexml/document'
require 'lazy_xml_model/version'
require 'lazy_xml_model/attribute_node'
require 'lazy_xml_model/element_node'
require 'lazy_xml_model/has_one_association'
require 'lazy_xml_model/has_many_association'

module LazyXmlModel
  extend ActiveSupport::Concern

  included do
    include AttributeNode
    include HasManyAssociation
    include HasOneAssociation
    include ElementNode

    attr_writer :xml_doc
    attr_accessor :parent_xml_doc
    cattr_accessor :tag

    #
    # Class Methods
    #
    def self.build_from_xml_str(xml_string)
      object = self.new
      object.parent_xml_doc = REXML::Document.new(xml_string)
      object.xml_doc = object.parent_xml_doc.root
      object
    end

    def self.build_from_xml_doc(xml_doc)
      object = self.new
      object.xml_doc = xml_doc
      object
    end
  end

  #
  # Instance Methods
  #
  def xml_doc
    @xml_doc ||= default_xml_doc
  end

  def to_xml
    output = ''

    if root_node?
      parent_xml_doc.write(output)
    else
      REXML::Formatters::Pretty.new.write(xml_doc, output)
    end
    output
  end

  def delete
    raise StandardError, 'You cannot delete the root node of a document!' if root_node?

    parent_xml_doc.delete(xml_doc)
  end

  # NOTE: This is required by rails FormHelper#fields_for to used nested forms
  def persisted?
    false
  end

  private

  def default_xml_doc
    REXML::Document.new("<#{root_tag}/>").root
  end

  def root_tag
    self.tag || self.class.name.demodulize.downcase
  end

  def root_node?
    parent_xml_doc.is_a? REXML::Document
  end
end

