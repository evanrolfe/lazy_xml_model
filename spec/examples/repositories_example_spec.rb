class Image < XmlRecord
  attribute_node :name
  attribute_node :displayname

  has_many :repositories, class_name: 'Repository'
end

class Repository < XmlRecord
  attribute_node :type
  attribute_node :priority
  attribute_node :alias

  has_one :source, class_name: 'Source'

  def _destroy
    false
  end
end

class Source < XmlRecord
  attribute_node :path
end

RSpec.describe LazyXmlModel do
  let(:xml_str) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
  <repository type="apt-deb" priority="10" alias="debian" imageinclude="true" password="123456" prefer-license="true" status="replaceable" username="Tom">
    <source path="http://one.com"/>
  </repository>
  <repository type="rpm-dir" priority="20" imageinclude="false" prefer-license="false">
    <source path="http://two.com"/>
  </repository>
  <repository type="yast2" priority="20">
    <source path="http://three.com"/>
  </repository>
  <repository type="rpm-md">
    <source path="http://four.com"/>
  </repository>
</image>
XML
  end

  describe 'deleting a repository' do
    let(:expected_xml_str) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
  <repository type="rpm-dir" priority="20" imageinclude="false" prefer-license="false">
    <source path="http://two.com"/>
  </repository>
  <repository type="yast2" priority="20">
    <source path="http://three.com"/>
  </repository>
  <repository type="rpm-md">
    <source path="http://four.com"/>
  </repository>
</image>
XML
    end
    let(:image) { Image.build_from_xml_str(xml_str) }
    let(:update_attributes) do
      {
        "name" => "Christians_openSUSE_13.2_JeOS",
        "displayname" => "Christians_openSUSE_13.2_JeOS",
        "repositories_attributes"=>
        {
          "0" => {
            "type" => "apt-deb",
            "_destroy" => "1",
            "source_attributes" => {
              "path" => "http://one.com"
            }
          },
         "1" => {
            "type" => "rpm-dir",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://two.com"
            }
          },
         "2" => {
            "type" => "yast2",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://three.com"
            }
          },
         "3" => {
            "type" => "rpm-md",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://four.com"
            }
          }
        }
      }
    end

    before do
      image.assign_attributes(update_attributes)
    end

    it 'returns the expected xml' do
      expect(image.to_xml).to eq(expected_xml_str)
    end
  end

  describe 'deleting two repositories' do
    let(:expected_xml_str) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
  <repository type="rpm-dir" priority="20" imageinclude="false" prefer-license="false">
    <source path="http://two-has-changed.com"/>
  </repository>
  <repository type="rpm-md">
    <source path="http://four-has-changed.com"/>
  </repository>
</image>
XML
    end
    let(:image) { Image.build_from_xml_str(xml_str) }
    let(:update_attributes) do
      {
        "name" => "Christians_openSUSE_13.2_JeOS",
        "displayname" => "Christians_openSUSE_13.2_JeOS",
        "repositories_attributes"=>
        {
          "0" => {
            "type" => "apt-deb",
            "_destroy" => "1",
            "source_attributes" => {
              "path" => "http://one.com"
            }
          },
         "1" => {
            "type" => "rpm-dir",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://two-has-changed.com"
            }
          },
         "2" => {
            "type" => "yast2",
            "_destroy" => "1",
            "source_attributes" => {
              "path" => "http://three.com"
            }
          },
         "3" => {
            "type" => "rpm-md",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://four-has-changed.com"
            }
          }
        }
      }
    end

    before do
      image.assign_attributes(update_attributes)
    end

    it 'returns the expected xml' do
      expect(image.to_xml).to eq(expected_xml_str)
    end
  end

  describe 'deleting two repositories and adding a repository' do
    let(:expected_xml_str) do
<<-XML
<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
  <repository type="rpm-dir" priority="20" imageinclude="false" prefer-license="false">
    <source path="http://two-has-changed.com"/>
  </repository>
  <repository type="rpm-md">
    <source path="http://four-has-changed.com"/>
  </repository>
  <repository type="yast2">
    <source path="http://five-is-new.com"/>
  </repository>
</image>
XML
    end
    let(:image) { Image.build_from_xml_str(xml_str) }
    let(:update_attributes) do
      {
        "name" => "Christians_openSUSE_13.2_JeOS",
        "displayname" => "Christians_openSUSE_13.2_JeOS",
        "repositories_attributes"=>
        {
          "0" => {
            "type" => "apt-deb",
            "_destroy" => "1",
            "source_attributes" => {
              "path" => "http://one.com"
            }
          },
         "1" => {
            "type" => "rpm-dir",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://two-has-changed.com"
            }
          },
         "2" => {
            "type" => "yast2",
            "_destroy" => "1",
            "source_attributes" => {
              "path" => "http://three.com"
            }
          },
         "3" => {
            "type" => "rpm-md",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://four-has-changed.com"
            }
          },
         "4" => {
            "type" => "yast2",
            "_destroy" => "0",
            "source_attributes" => {
              "path" => "http://five-is-new.com"
            }
          }
        }
      }
    end

    before do
      image.assign_attributes(update_attributes)
    end

    it 'returns the expected xml' do
      expect(image.to_xml).to eq(expected_xml_str)
    end
  end
end
