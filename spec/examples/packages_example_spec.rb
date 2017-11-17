module Example
  class Image < XmlRecord
    attribute_node :name
    attribute_node :displayname

    has_many :package_groups, class_name: 'Example::PackageGroup'
  end

  class PackageGroup < XmlRecord
    attribute_node :type
    attribute_node :patternType

    self.tag = 'packages'

    has_many :packages, class_name: 'Example::Package'
  end

  class Package < XmlRecord
    attribute_node :name

    self.tag = 'package'
  end
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
  <packages type="image" patternType="onlyRequired">
    <package name="e2fsprogs"/>
    <package name="aaa_base"/>
    <package name="branding-openSUSE"/>
    <package name="patterns-openSUSE-base"/>
    <package name="grub2"/>
    <package name="hwinfo"/>
    <package name="iputils"/>
    <package name="kernel-default"/>
    <package name="netcfg"/>
    <package name="openSUSE-build-key"/>
    <package name="openssh"/>
    <package name="plymouth"/>
    <package name="polkit-default-privs"/>
    <package name="rpcbind"/>
    <package name="syslog-ng"/>
    <package name="vim"/>
    <package name="zypper"/>
    <package name="timezone"/>
    <package name="openSUSE-release-dvd"/>
    <package name="gfxboot-devel" bootinclude="true"/>
  </packages>
  <packages type="delete">
    <package name="e2fsprogss"/>
  </packages>
</image>
XML
  end

  describe 'getting a package' do
    let(:image) { Example::Image.build_from_xml_str(xml_str) }

    it 'parses the package groups' do
      expect(image.package_groups.count).to eq(2)
      expect(image.package_groups[0].packages.count).to eq(20)
      expect(image.package_groups[1].packages.count).to eq(1)
    end
  end

   describe 'updating & deleting packages' do
     let(:expected_xml_str) do
 <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<image name="Christians_openSUSE_13.2_JeOS" displayname="Christians_openSUSE_13.2_JeOS" schemaversion="5.2">
  <description type="system">
    <author>Christian Bruckmayer</author>
    <contact>noemail@example.com</contact>
    <specification>Tiny, minimalistic appliances</specification>
  </description>
  <packages type="image" patternType="onlyRequired">
    <package name="e2fsprogs"/>
    <package name="aaa_base"/>
    <package name="branding-openSUSE"/>
    <package name="patterns-openSUSE-base"/>
    <package name="grub2"/>
    <package name="hwinfo"/>
    <package name="iputils"/>
    <package name="kernel-default"/>
    <package name="netcfg"/>
    <package name="openSUSE-build-key"/>
    <package name="openssh"/>
    <package name="plymouth"/>
    <package name="polkit-default-privs"/>
    <package name="rpcbind"/>
    <package name="syslog-ng"/>
    <package name="vim2.0CHANGED"/>
    <package name="zypper"/>
    <package name="openSUSE-release-dvd"/>
    <package name="CHANGED" bootinclude="true"/>
  </packages>
  <packages type="delete">
    <package name="e2fsprogss"/>
  </packages>
</image>
 XML
     end
     let(:image) { Example::Image.build_from_xml_str(xml_str) }

     let(:update_attributes) do
       {
         "package_groups_attributes"=>
         {
           "0" => {
             "type" => "image",
             "_destroy" => "0",
             "packages_attributes" => {
               "0" => { "name" => "e2fsprogs", "_destroy" => "0" },
               "1" => { "name" => "aaa_base", "_destroy" => "0" },
               "2" => { "name" => "branding-openSUSE", "_destroy" => "0" },
               "3" => { "name" => "patterns-openSUSE-base", "_destroy" => "0" },
               "4" => { "name" => "grub2", "_destroy" => "0" },
               "5" => { "name" => "hwinfo", "_destroy" => "0" },
               "6" => { "name" => "iputils", "_destroy" => "0" },
               "7" => { "name" => "kernel-default", "_destroy" => "0" },
               "8" => { "name" => "netcfg", "_destroy" => "0" },
               "9" => { "name" => "openSUSE-build-key", "_destroy" => "0" },
               "10" => { "name" => "openssh", "_destroy" => "0" },
               "11" => { "name" => "plymouth", "_destroy" => "0" },
               "12" => { "name" => "polkit-default-privs", "_destroy" => "0" },
               "13" => { "name" => "rpcbind", "_destroy" => "0" },
               "14" => { "name" => "syslog-ng", "_destroy" => "0" },
               "15" => { "name" => "vim2.0CHANGED", "_destroy" => "0" },
               "16" => { "name" => "zypper", "_destroy" => "0" },
               "17" => { "name" => "timezone", "_destroy" => "1" },
               "18" => { "name" => "openSUSE-release-dvd", "_destroy" => "0" },
               "19" => { "name" => "CHANGED", "_destroy" => "0" }
             }
           }
         }
       }
     end

     before do
       image.assign_attributes(update_attributes)
     end

     it 'updates the package object' do
      expect(image.package_groups[0].packages[15].name).to eq('vim2.0CHANGED')
      expect(image.package_groups[0].packages[18].name).to eq('CHANGED')
     end

     it 'outputs the correct xml' do
      expect(image.to_xml).to eq(expected_xml_str)
     end
   end
end
