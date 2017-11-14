RSpec.shared_context 'example xml' do
  let(:company_xml_str) do
<<-XML
<?xml version='1.0' encoding='UTF-8'?>
<company name='SUSE'>
  <description type='about'>
    <foundingyear>1992</foundingyear>
    <numberemployees>~1000</numberemployees>
    <headquarters>Nuremberg</headquarters>
    <website>http://www.suse.com</website>
  </description>
</company>
XML
  end
end
