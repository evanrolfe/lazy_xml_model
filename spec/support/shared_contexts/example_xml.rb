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

  <employee name='Tanya Erickson'>
    <jobtitle>Chief Marketing Synergist</jobtitle>
    <yearjoined>2001</yearjoined>
  </employee>

  <employee name='Rolando Garcia'>
    <jobtitle>Human Integration Coordinator</jobtitle>
    <yearjoined>2013</yearjoined>
  </employee>

  <employee name='Xavier Bringham'>
    <jobtitle>Regional Markets Executive</jobtitle>
    <yearjoined>2017</yearjoined>
  </employee>
</company>
XML
  end
end
