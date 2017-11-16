RSpec.describe LazyXmlModel do
  describe '.attribute_node' do
    context 'when building from an xml string' do
      include_context 'example xml'

      let(:company) { Company.build_from_xml_str(company_xml_str) }

      it 'parses the attributes' do
        expect(company.name).to eq('SUSE')
      end

      it 'lets you set the attribute' do
        company.name = 'Microsoft'
        expect(company.name).to eq('Microsoft')
      end
    end

    context 'when instantiating a blank object' do
      let(:company) { Company.new }
      let(:expected_xml) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<company name="Microsoft"/>
XML
      end
      it 'lets you set the attribute' do
        company.name = 'Microsoft'

        expect(company.name).to eq('Microsoft')
        expect(company.to_xml).to eq(expected_xml)
      end
    end
  end
end
