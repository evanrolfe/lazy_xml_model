RSpec.describe LazyXmlModel do
  include_context 'example xml'

  describe '#collection' do
    let(:company) { Company.build_from_xml_str(company_xml_str) }

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
        expect(company.to_xml).to include('<employee', new_employee.name, new_employee.jobtitle)
      end
    end

    context 'on a collection with elements' do
      let(:company) { Company.build_from_xml_str(company_xml_str) }

      before do
        company.employees << new_employee
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(4)
        expect(company.employees[3]).to eq(new_employee)
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include('<employee', new_employee.name, new_employee.jobtitle)
      end
    end
  end

  describe '#collection.delete' do
    let(:company) { Company.build_from_xml_str(company_xml_str) }
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
    let(:company) { Company.build_from_xml_str(company_xml_str) }

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

      context 'on a collection with elements' do
        let(:company) { Company.build_from_xml_str(company_xml_str) }

        before do
          company.employees.build
          company.employees[3].name = 'Kurt Campbell'
          company.employees[3].jobtitle = 'Senior XML Specialist'
        end

        it 'adds the object to the collection' do
          expect(company.employees.count).to eq(4)
          expect(company.employees[3]).to have_attributes(
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
    let(:employee1_attributes) { { name: 'Kurt Campbell', jobtitle: 'Senior XML Specialist' } }
    let(:employee2_attributes) { { name: 'Julie McKenzie', jobtitle: 'Lead Gem Designer' } }
    let(:employee3_attributes) { { name: 'Doris Beckminster', jobtitle: 'Corporate Interactions Adviser' } }

    context 'on an empty collection' do
      let(:company) { Company.new }

      before do
        company.employees_attributes = { '0' => employee1_attributes, '1' => employee2_attributes }
      end

      it 'adds the object to the collection' do
        expect(company.employees.count).to eq(2)
        expect(company.employees[0]).to have_attributes(employee1_attributes)
        expect(company.employees[1]).to have_attributes(employee2_attributes)
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
          '1' => { _destroy: true },   # Employee2 gets deleted
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
        expect(company.to_xml).not_to include(*employee2_attributes.values)
      end

      it 'adds new objects' do
        expect(company.employees[1]).to have_attributes(employee3_attributes)
      end
    end
  end
end
