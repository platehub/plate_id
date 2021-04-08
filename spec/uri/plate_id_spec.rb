RSpec.describe URI::PlateID do
  describe ".parse" do
    it "does not raise an error when id is given" do
      expect { described_class.parse("plateid://ContentModel/ElementType/9") }.not_to(raise_error)
    end

    it "does not raise an error when no id is given" do
      expect { described_class.parse("plateid://ContentModel/ElementType") }.not_to(raise_error)
    end

    it "raises InvalidComponentError when no valid uri string is passed" do
      expect { described_class.parse("plateid://notavaliduri") }.to(
        raise_error(URI::InvalidComponentError)
      )
    end

    it "raises InvalidComponentError when valid string is passed, but is not in mapping" do
      expect { described_class.parse("plateid://ContentModel/OjbectType/1") }.to(
        raise_error(URI::InvalidComponentError)
      )
    end
  end

  describe ".create" do
    context "with instance passed" do
      let(:model_class) { double(:model_class, name: "Ngn::ContentModel::ElementType") }
      let(:model) { double(:element_type, class: model_class, id: 1234) }

      it "calls .build with model_name and id" do
        expect(described_class).to receive(:build).with(
          model_name: "Ngn::ContentModel::ElementType",
          model_id: 1234
        )
        described_class.create(model)
      end
    end
  end

  describe ".build" do
    {
      "Site" => "Base/Site",
      "Org::Site" => "Base/Site",
      "Ngn::Site" => "Base/Site",
      "Ngn::Attachment" => "Base/Attachment",
      "Ngn::AttachmentSetting" => "Base/AttachmentSetting",
      "Ngn::AttachmentFolder" => "Base/AttachmentFolder",
      "Ngn::Domain" => "Base/Domain",
      "Ngn::ClipboardItem" => "Base/ClipboardItem",
      "Ngn::VersionControl::Actions::Action" => "Base/VersionControl",

      "Ngn::Content::Post" => "Content/Post",
      "Ngn::Content::Section" => "Content/Section",
      "Ngn::Content::Row" => "Content/Row",
      "Ngn::Content::Column" => "Content/Column",
      "Ngn::Content::Element" => "Content/Element",
      "Ngn::Content::ContentObject" => "Content/ContentObject",
      "Ngn::Content::SiteTranslation" => "Content/SiteTranslation",
      "Ngn::Content::AuthenticationObject" => "Content/AuthenticationObject",

      "Ngn::ContentModel::ContentField" => "ContentModel/ContentField",
      "Ngn::ContentModel::ContentFieldTab" => "ContentModel/ContentFieldGroup",
      "Ngn::ContentModel::PostType" => "ContentModel/PostType",
      "Ngn::ContentModel::SectionType" => "ContentModel/SectionType",
      "Ngn::ContentModel::ElementType" => "ContentModel/ElementType",
      "Ngn::ContentModel::ObjectTypeKind" => "ContentModel/ContentType",
      "Ngn::ContentModel::ObjectType" => "ContentModel/ObjectType",
      "Ngn::ContentModel::TrayType" => "ContentModel/TrayType",
      "Ngn::ContentModel::AuthenticationType" => "ContentModel/AuthenticationType",

      "Ngn::Theming::SiteTheme" => "Theming/Theme",
      "Ngn::Theming::ThemeFile" => "Theming/ThemeFile",
      "Ngn::Theming::Prerender" => "Theming/Prerender",

      "Org::Auth::User" => "Auth/User",
      "Api::Integration" => "Auth/ApiIntegration",

      "Org::Company" => "Organization/Company",
      "Org::Partner" => "Organization/Partner",
      "Org::FormMessage" => "Organization/FormMessage",

      "AccessControl::Policy" => "AccessControl/Policy",
      "AccessControl::Group" => "AccessControl/Group",
      "AccessControl::Role" => "AccessControl/Role"
    }.each do |klass, mapped_klass|
      it "returns correct PlateID uri if model_name is #{klass}" do
        expect(described_class.build(model_name: klass, model_id: 1234).to_s).to eq(
          "plateid://#{mapped_klass}/1234"
        )
      end
    end

    it "returns nil when invalid class is passed" do
      expect(described_class.build(model_name: "Ngn::Content::InvalidClass", model_id: 1234)).to be_nil
    end
  end
end
