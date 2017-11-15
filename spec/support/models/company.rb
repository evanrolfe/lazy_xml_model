class Company < XmlRecord
  attribute_node :name
  has_one :description, class_name: 'Description'
end

class Description < XmlRecord
  attribute_node :type

  element_node :foundingyear
  element_node :numberemployees
  element_node :headquarters
  element_node :website
end

class Employee < XmlRecord
  attribute_node :name

  element_node :jobtitle
  element_node :yearjoined
end
