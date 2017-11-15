class CompanyBasic
  include LazyXmlModel

  attribute_node :name
  has_one :description, class_name: 'DescriptionBasic'
  has_many :employees, class_name: 'EmployeeBasic'
end

class DescriptionBasic
  include LazyXmlModel

  attribute_node :type

  element_node :foundingyear
  element_node :numberemployees
  element_node :headquarters
  element_node :website

  self.tag = 'description'
end

class EmployeeBasic
  include LazyXmlModel

  attribute_node :name

  element_node :jobtitle
  element_node :yearjoined

  self.tag = 'employee'
end
