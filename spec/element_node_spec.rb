RSpec.describe LazyXmlModel do
  describe '.element_node' do
    context 'when building from an xml string' do
      include_context 'example xml'

      let(:company) { Company.build_from_xml_str(company_xml_str) }

      it 'parses the elements' do
        expect(company.description.type).to eq('about')
        expect(company.description.foundingyear).to eq('1992')
        expect(company.description.numberemployees).to eq('~1000')
        expect(company.description.headquarters).to eq('Nuremberg')
        expect(company.description.website).to eq('http://www.suse.com')
      end

      it 'lets you update the elements' do
        company.description.foundingyear = '1982'
        expect(company.description.foundingyear).to eq('1982')
      end

      it 'lets you delete an element' do
        company.description.foundingyear = nil
        expect(company.to_xml).to include('<foundingyear/>')
      end
    end

    context 'when setting the elements on a blank object' do
      let(:company) { Company.new }

      before do
        company.build_description
        company.description.foundingyear = '2017'
        company.description.headquarters = 'Manchester'
      end

      it 'lets you set the attributes' do
        expect(company.to_xml).to include(
          '<description>',
          '<foundingyear>',
          '2017',
          '<headquarters>',
          'Manchester'
        )
      end
    end
  end
end
