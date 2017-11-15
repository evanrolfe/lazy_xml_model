class Company < XmlRecord
  attribute_node :name
  object_node :description, class_name: 'Description'
end
