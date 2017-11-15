RSpec.describe LazyXmlModel do
  describe 'object getter method' do
    include_context 'example xml'

    let(:company) { Company.build_from_xml_str(company_xml_str) }

    it 'parses the attributes' do
      expect(company.description).to have_attributes(
        type: 'about',
        foundingyear: '1992',
        numberemployees: '~1000',
        headquarters: 'Nuremberg',
        website: 'http://www.suse.com'
      )
    end
  end

  describe 'object setter method' do
    let(:company) { Company.new }
    let(:description) { Description.new }

    before do
      company.description = description
    end

    it 'sets the object' do
      expect(company.description).to eq(description)
    end

    it 'includes the object in the xml output' do
      expect(company.to_xml).to include(description.to_xml)
    end
  end

  describe 'object builder method' do
    context 'on an object that includes ActiveModel' do
      let(:company) { Company.new }

      before do
        company.build_description(type: 'about')
      end

      it 'sets the object' do
        expect(company.description.type).to eq('about')
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include('description', 'type', 'about')
      end
    end

    context 'on an object that does not includes ActiveModel' do
      let(:company) { CompanyBasic.new }

      before do
        company.build_description
        company.description.type = 'about'
      end

      it 'sets the object' do
        expect(company.description.type).to eq('about')
      end

      it 'includes the object in the xml output' do
        expect(company.to_xml).to include('description', 'type', 'about')
      end
    end
  end

  # _attributes= Builder Method
  describe 'object _attributes= method' do
    let(:company) { Company.new }

    before do
      company.description_attributes = { type: 'about', foundingyear: '1992' }
    end

    it 'sets the object' do
      expect(company.description.type).to eq('about')
      expect(company.description.foundingyear).to eq('1992')
    end

    it 'includes the object in the xml output' do
      expect(company.to_xml).to include('description', 'type', 'about', 'foundingyear', '1992')
    end
  end

  # Delete method
  describe 'object delete method' do
    include_context 'example xml'

    let(:company) { Company.build_from_xml_str(company_xml_str) }

    before do
      company.description.delete
    end

    it 'deletes the objects xml' do
      expect(company.to_xml).not_to include('description')
    end

    it 'deletes the object' do
      expect(company.description).to be_nil
    end
  end
end
