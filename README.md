# LazyXmlModel
Lets you modify xml files using ruby models with an interface similar to ActiveRecord models. It also lazily evaluates the xml file so you do not have to specify a model which covers the entire xml file. This is useful if you only want to modify certain parts of an xml file but do not care about the other contents.

## Installation
Install the gem:
```bash
gem install lazy_xml_model
```

And require it from your ruby file:
```ruby
require 'lazy_xml_model'
```
## Usage
Example XML file `company.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<company name="SUSE">
  <description type="about">
    <headquarters>Nuremberg</headquarters>
    <website>http://www.suse.com</website>
  </description>
  <trading>yes</trading>
  <employee name="Tanya Erickson">
    <jobtitle>Chief Marketing Synergist</jobtitle>
  </employee>
  <employee name="Rolando Garcia">
    <jobtitle>Human Integration Coordinator</jobtitle>
  </employee>
  <employee name="Xavier Bringham">
    <jobtitle>Regional Markets Executive</jobtitle>
  </employee>
</company>
```
Ruby models:
```ruby
class Company
  include LazyXmlModel

  attribute_node :name
  element_node :trading

  has_one :description, class_name: 'Description'
  has_many :employees, class_name: 'Employee'
end

class Description
  include LazyXmlModel

  element_node :headquarters
  element_node :website
end

class Employee
  include LazyXmlModel

  attribute_node :name
  element_node :jobtitle
end
```
**Parsing the xml:**
```ruby
xml_str = File.read('company.xml')
company = Company.parse(xml_str)
```

**Accessing elements & attributes:**
```ruby
company.name
# => 'SUSE'
company.trading
# => 'yes'
company.name = 'openSuse'
company.trading = 'no'
```
**has_one associations:**
```ruby
company.description.headquarters
# => 'Nuremberg'
company.description.destroy # Removes the <description> tag from the xml
company.description
# => nil
company.build_description # Adds a new Description object and <description/> tag
company.description.headquarters = 'Prague' # Sets the value on the new description
```
**has_many associations:**
```ruby
company.employees[0].name
# => 'Tanya Erickson'
company.employees[0].jobtitle
# => 'Chief Marketing Synergist'
company.employees[0].delete # Deletes the employee
company.employees.build # Adds a new blank employee to the collection
company.employees.delete_all
```
**Add a new item to has_many association:**
```ruby
new_employee = Employee.new
new_employee.name = 'Evan Rolfe'
new_employee.jobtitle = 'Junior Xml Parser'
company.employees << new_employee
```
**Outputting the xml:**
```ruby
company.to_xml
```

**Validating the XML input**
```ruby
company = Company.parse('<company name="an invalid company!">')
company.xml_document.errors
# => => [#<Nokogiri::XML::SyntaxError: 1:37: FATAL: Premature end of data in tag company line 1>]
```

## Integrating with ActiveModel

LazyXmlModel plays nicely with ActiveModel so you can have nice things like mass assignment and validations on your xml models.
```ruby
class Company
  include LazyXmlModel
  include ActiveModel::Model
  include ActiveModel::Validations

  attribute_node :name
  element_node :trading

  has_one :description, class_name: 'Description'
  has_many :employees, class_name: 'Employee'

  validates :name, presence: true
  validates :trading, inclusion: { in: %w(yes no) }
end
```

**Validating the object:**
```ruby
company = Company.new(name: 'My Company', trading: 'i dont know')
company.valid?
# => false
company.errors.messages
# => {:trading=>["is not included in the list"]}
```

**Validating the xml content:**
Example XML file `company.xml`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<company>
  <trading>yes</trading>
</company>
```
```ruby
xml_str = File.read('company.xml')
company = Company.parse(xml_str)
company.valid?
# => false
company.errors.messages
# => {:name=>["can't be blank"]}
```
## Integrating with rails nested forms
If you include ActiveModel on your models then LazyXmlMapping gives you an `_attributes=` method on your has_one and has_many associations which means the models can be used with `fields_for` in the same way that an ActiveRecord model which calls `accepts_nested_attributes_for` works.

```html
<%= form_for(company) do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name %>
  </div>

  <div class="form-group">
    <%= f.label :trading %>
    <%= f.text_field :trading %>
  </div>

  <%= f.fields_for :description do |description_fields| %>
    <div class="form-group">
      <%= description_fields.label :headquarters %>
      <%= description_fields.text_field :headquarters %>
    </div>

    <div class="form-group">
      <%= description_fields.label :website %>
      <%= description_fields.text_field :website %>
    </div>
  <% end %>

  <%= f.fields_for :employees, f.object.employees.to_a do |employees_fields| %>
    <hr/>
    <div class="row">
      <b>Employee:</b>
    </div>

    <div class="form-group">
      <%= employees_fields.label :name %>
      <%= employees_fields.text_field :name %>
    </div>

    <div class="form-group">
      <%= employees_fields.label :jobtitle %>
      <%= employees_fields.text_field :jobtitle %>
    </div>

    <div class="form-group">
      <label class="form-check-label">
        <%= employees_fields.check_box :_destroy %>
        Delete?
      </label>
    </div>
  <% end %>

  <%= f.submit 'Save' %>
<% end %>

```

## TODO

* Validate associated objects as well as the root object
* Handle a collection of elements like:
```xml
<element>value1</element>
<element>value2</element>
<element>value3</element>
```
