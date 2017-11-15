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
end
