RSpec.describe LazyXmlModel do
  describe '#to_xml' do
    include_context 'example xml'

    let(:company) { Company.parse(company_xml_str) }

    it 'returns xml which respects the existing whitespace and xml declaration statement' do
      expect(company.to_xml).to eq(company_xml_str)
    end
  end
end
