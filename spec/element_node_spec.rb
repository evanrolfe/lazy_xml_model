RSpec.describe LazyXmlModel do
  describe 'getting the element' do
    context 'when the element exists in the xml' do
      include_context 'example xml'

      let(:company) { Company.build_from_xml_str(company_xml_str) }

      it 'returns the value of the element' do
        expect(company.trading).to eq('yes')
      end
    end

    context 'when the element doesnt exist in the xml' do
      let(:company) { Company.build_from_xml_str('<company/>') }

      it 'returns nil' do
        expect(company.trading).to be_nil
      end
    end
  end

  describe 'setting the element' do
    context 'when the element exists in the xml' do
      include_context 'example xml'

      let(:company) { Company.build_from_xml_str(company_xml_str) }

      before do
        company.trading = 'no'
      end

      it 'updates the elements value' do
        expect(company.trading).to eq('no')
      end
    end

    context 'when the element doesnt exist in the xml' do
      let(:company) { Company.build_from_xml_str('<company/>') }

      before do
        company.trading = 'no'
      end

      it 'creates the element with the right value' do
        expect(company.trading).to eq('no')
      end
    end

    context 'when setting the elements on a blank object' do
      let(:company) { Company.new }
      let(:expected_xml) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<company>
  <trading>no</trading>
</company>
XML
      end

      before do
        company.trading = 'no'
      end

      it 'creates the element with the right value' do
        expect(company.trading).to eq('no')
        expect(company.to_xml).to eq(expected_xml)
      end
    end
  end
end
