RSpec.describe LazyXmlModel do
  include_context 'example xml'

  describe '#collection' do
    let(:company) { Company.parse(company_xml_str) }

    it 'parses the collection' do
      expect(company.employees.count).to eq(3)

      expect(company.employees[0]).to have_attributes(
        name: 'Tanya Erickson',
        jobtitle: 'Chief Marketing Synergist',
        yearjoined: '2001'
      )

      expect(company.employees[1]).to have_attributes(
        name: 'Rolando Garcia',
        jobtitle: 'Human Integration Coordinator',
        yearjoined: '2013'
      )

      expect(company.employees[2]).to have_attributes(
        name: 'Xavier Bringham',
        jobtitle: 'Regional Markets Executive',
        yearjoined: '2017'
      )
    end
  end

  describe '#collection<<' do
    let(:new_employee) { Employee.new(name: 'Kurt Campbell', jobtitle: 'Senior XML Specialist') }
    let(:expected_xml) do
<<-XML
  <employee name=\"Kurt Campbell\">
    <jobtitle>Senior XML Specialist</jobtitle>
  </employee>
XML
    end

    context 'on an empty collection' do
      let(:company) { Company.new }

      before do
        company.employees << new_employee
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(1)
        expect(company.employees[0]).to eq(new_employee)
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include(expected_xml)
      end
    end

    context 'on a collection with elements' do
      let(:company) { Company.parse(company_xml_str) }

      before do
        company.employees << new_employee
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(4)
        expect(company.employees[3]).to eq(new_employee)
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include(expected_xml)
      end
    end
  end

  describe '#collection.delete' do
    let(:company) { Company.parse(company_xml_str) }
    let(:deleted_employee) { company.employees[0] }

    before do
      company.employees.delete(deleted_employee)
    end

    it 'removes the object from the collection' do
      expect(company.employees).not_to include(deleted_employee)
    end

    it 'removes the object from the xml output' do
      expect(company.to_xml).not_to include(deleted_employee.name, deleted_employee.jobtitle)
    end
  end

  describe '#collection.delete_all' do
    let(:company) { Company.parse(company_xml_str) }

    before do
      company.employees.delete_all
    end

    it 'removes the objects from the collection' do
      expect(company.employees.empty?).to be_truthy
    end

    it 'removes the object from the xml output' do
      expect(company.to_xml).not_to include(
        '<employee',
        'Tanya Erickson',
        'Chief Marketing Synergist',
        '2001',
        'Rolando Garcia',
        'Human Integration Coordinator',
        '2013',
        'Xavier Bringham',
        'Regional Markets Executive',
        '2017'
      )
    end
  end

  describe '#collection.build' do
    context 'without arguments' do
      context 'on an empty collection' do
        let(:company) { Company.new }
        let(:expected_xml) do
          <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<company>
  <employee name="Kurt Campbell">
    <jobtitle>Senior XML Specialist</jobtitle>
  </employee>
</company>
          XML
        end

        subject { company.employees.build }

        before do
          subject.name = 'Kurt Campbell'
          subject.jobtitle = 'Senior XML Specialist'
        end

        it 'returns the new object' do
          expect(subject).to be_an(Employee)
        end

        it 'adds the object to the collection' do
          expect(company.employees.count).to eq(1)
          expect(company.employees[0]).to have_attributes(
            name: 'Kurt Campbell',
            jobtitle: 'Senior XML Specialist'
          )
        end

        it 'includes the object in the xml output' do
          expect(company.to_xml).to eq(expected_xml)
        end
      end

      context 'on a collection with elements' do
        let(:company) { Company.parse(company_xml_str) }

        before do
          company.employees.build
          company.employees.last.name = 'Kurt Campbell'
          company.employees.last.jobtitle = 'Senior XML Specialist'
        end

        it 'adds the object to the collection' do
          expect(company.employees.count).to eq(4)
          expect(company.employees.last).to have_attributes(
            name: 'Kurt Campbell',
            jobtitle: 'Senior XML Specialist'
          )
        end

        it 'includes the object in the xml output' do
          expect(company.to_xml).to include('<employee', 'Kurt Campbell', 'Senior XML Specialist')
        end
      end

      context 'on a collection for an object that does not includes ActiveModel' do
        let(:company) { CompanyBasic.new }

        before do
          company.employees.build
          company.employees[0].name = 'Kurt Campbell'
          company.employees[0].jobtitle = 'Senior XML Specialist'
        end

        it 'adds the object to the collection' do
          expect(company.employees.count).to eq(1)
          expect(company.employees[0]).to have_attributes(
            name: 'Kurt Campbell',
            jobtitle: 'Senior XML Specialist'
          )
        end

        it 'includes the object in the xml output' do
          expect(company.to_xml).to include('<employee', 'Kurt Campbell', 'Senior XML Specialist')
        end
      end
    end

    context 'with arguments' do
      let(:company) { Company.new }
      let(:employee_attributes) { { name: 'Kurt Campbell', jobtitle: 'Senior XML Specialist' } }

      before do
        company.employees.build(employee_attributes)
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(1)
        expect(company.employees[0]).to have_attributes(employee_attributes)
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include('<employee', 'Kurt Campbell', 'Senior XML Specialist')
      end
    end
  end

  describe '#collection_attributes=' do
    let(:employee1_attributes) { { name: 'Kurt Campbell', jobtitle: 'Senior XML Specialist', _destroy: '0' } }
    let(:employee2_attributes) { { name: 'Julie McKenzie', jobtitle: 'Lead Gem Designer', _destroy: '0' } }
    let(:employee3_attributes) { { name: 'Doris Beckminster', jobtitle: 'Corporate Interactions Adviser', _destroy: '0' } }

    context 'on an empty collection' do
      let(:company) { Company.new }

      before do
        company.employees_attributes = { '0' => employee1_attributes, '1' => employee2_attributes }
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(2)
        expect(company.employees[0]).to have_attributes(employee1_attributes.except(:_destroy))
        expect(company.employees[1]).to have_attributes(employee2_attributes.except(:_destroy))
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include(
          '<employee',
          'Kurt Campbell',
          'Senior XML Specialist',
          'Julie McKenzie',
          'Lead Gem Designer'
        )
      end
    end

    context 'on a collection with elements' do
      let(:company) { Company.new }

      before do
        # 1. Create the two employees
        company.employees_attributes = {
          '0' => employee1_attributes,
          '1' => employee2_attributes
        }

        # 2. Update the employees
        employee1_attributes[:jobtitle] = 'Senior XML Strategist'

        company.employees_attributes = {
          '0' => employee1_attributes, # Employee1 gets jobtitle updated
          '1' => { _destroy: '1' },    # Employee2 gets deleted
          '2' => employee3_attributes  # Employee3 is added
        }
      end

      it 'updates the existing objects' do
        expect(company.employees.count).to eq(2)
        expect(company.employees[0]).to have_attributes(
          name: 'Kurt Campbell',
          jobtitle: 'Senior XML Strategist'
        )
      end

      it 'deletes the objects to delete' do
        expect(company.to_xml).not_to include(*employee2_attributes.except(:_destroy).values)
      end

      it 'adds new objects' do
        expect(company.employees[1]).to have_attributes(employee3_attributes.except(:_destroy))
      end
    end
  end

  describe '#[]=' do
    let(:company) { Company.parse(company_xml_str) }
    let(:new_employee) { Employee.new }

    let(:expected_xml) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<company name="SUSE">
  <description type="about">
    <foundingyear>1992</foundingyear>
    <numberemployees>~1000</numberemployees>
    <headquarters>Nuremberg</headquarters>
    <website>http://www.suse.com</website>
  </description>
  <trading>yes</trading>
  <employee name="Evan Rolfe">
    <jobtitle>Junior Xml Parser</jobtitle>
  </employee>
  <employee name="Rolando Garcia">
    <jobtitle>Human Integration Coordinator</jobtitle>
    <yearjoined>2013</yearjoined>
  </employee>
  <employee name="Xavier Bringham">
    <jobtitle>Regional Markets Executive</jobtitle>
    <yearjoined>2017</yearjoined>
  </employee>
  <bla>
    <test>asdf</test>
  </bla>
</company>
  XML
    end

    before do
      new_employee.name = 'Evan Rolfe'
      new_employee.jobtitle = 'Junior Xml Parser'
      company.employees[0] = new_employee
    end

    it 'replaces the old employee object' do
      expect(company.employees[0]).to eq(new_employee)
    end

    it 'replaces the old employees xml' do
      expect(company.to_xml).to eq(expected_xml)
    end
  end
end
