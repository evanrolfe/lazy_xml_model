class CompanyBasic
  include LazyXmlModel

  attribute_node :name
  object_node :description, class_name: 'DescriptionBasic'
end
