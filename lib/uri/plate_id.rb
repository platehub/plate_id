require 'cgi'

module URI
  class PlateID < Generic

    # URI::PlateID encodes an Plate unique reference to a specific model as an URI
    # and notates it according to a mapping. The PlateID URI is meant for external
    # communication.
    #
    # The URI format looks like "plateid://group_name/base_class/id".

    attr_writer :id

    MAPPING = {
      "Site" => { host: "Base", base_class: "Site" },
      "Ngn::Attachment" => { host: "Base", base_class: "Attachment" },
      "Ngn::Domain" => { host: "Base", base_class: "Domain" },
      "Ngn::ClipboardItem" => { host: "Base", base_class: "ClipboardItem" },

      "Ngn::Content::Post" => { host: "Content", base_class: "Post" },
      "Ngn::Content::Section" => { host: "Content", base_class: "Section" },
      "Ngn::Content::Row" => { host: "Content", base_class: "Row" },
      "Ngn::Content::Column" => { host: "Content", base_class: "Column" },
      "Ngn::Content::Element" => { host: "Content", base_class: "Element" },
      "Ngn::Content::ContentObject" => { host: "Content", base_class: "ContentObject" },
      "Ngn::Content::SiteTranslation" => { host: "Content", base_class: "SiteTranslation" },

      "Ngn::ContentModel::ContentField" => { host: "ContentModel", base_class: "ContentField" },
      "Ngn::ContentModel::ContentFieldTab" => { host: "ContentModel", base_class: "ContentFieldGroup" },
      "Ngn::ContentModel::PostType" => { host: "ContentModel", base_class: "PostType" },
      "Ngn::ContentModel::SectionType" => { host: "ContentModel", base_class: "SectionType" },
      "Ngn::ContentModel::ElementType" => { host: "ContentModel", base_class: "ElementType" },
      "Ngn::ContentModel::ObjectTypeKind" => { host: "ContentModel", base_class: "ContentType" },
      "Ngn::ContentModel::TrayType" => { host: "ContentModel", base_class: "TrayType" },
      "Ngn::ContentModel::AuthenticationType" => { host: "ContentModel", base_class: "AuthenticationType" },

      "Ngn::Theming::SiteTheme" => { host: "Theming", base_class: "Theme" },
      "Ngn::Theming::ThemeFile" => { host: "Theming", base_class: "ThemeFile" },
      "Ngn::Theming::Prerender" => { host: "Theming", base_class: "Prerender" },

      "Org::Auth::User" => { host: "Auth", base_class: "User" },
      "Api::Integration" => { host: "Auth", base_class: "ApiIntegration" },

      "Org::Company" => { host: "Organization", base_class: "Company" },
      "Org::Partner" => { host: "Organization", base_class: "Partner" },
      "Org::FormMessage" => { host: "Organization", base_class: "FormMessage" },

      # Access control
      "AccessControl::Policy" => { host: "AccessControl", base_class: "Policy" }
    }

    attr_reader :base_class, :id

    class << self
      # Create a new URI::PlateID by parsing a plateid string with argument check.
      #
      #   URI::PlateID.parse 'plateid://Group/Class/1'
      #
      def parse(uri)
        generic_components = URI.split(uri) << nil << true # nil parser, true arg_check
        new(*generic_components)
      end

      # Shorthand to build a URI::PlateID from a model.
      #
      #   URI::PlateID.create(Ngn::Content::Post.find(5))
      #   URI::PlateID.create(Ngn::Content::Post)
      def create(model)
        model = model.new if model.class == Class
        build(model_name: model.class.name, model_id: model.id)
      end

      # Create a new URI::PlateID from components with argument check.
      #
      # The allowed components are model_name and model_id, which
      # can be either a hash or an array.
      #
      # Using a hash:
      #
      #   URI::PlateID.build(
      #     model_name: 'Ngn::ContentModel::ElementType',
      #     model_id: '1'
      #   )
      def build(args)
        comps = Util.make_components_hash(self, args)
        parts = MAPPING[comps[:model_name]].dup
        parts[:scheme] = comps[:scheme]
        parts[:id] = comps[:model_id]
        parts[:path] = "/#{parts[:base_class]}/#{CGI.escape(parts[:id].to_s)}"

        super(parts)
      end
    end

    # Implement #to_s to avoid no implicit conversion of nil into string when path is nil
    def to_s
      "plateid://#{host}/#{base_class}/#{id}"
    end

    protected

    def set_path(path)
      set_model_components(path) unless defined?(@model_name) && @model_id
      super
    end

    private

    COMPONENT = [:scheme, :host, :base_class, :id].freeze
    # Extracts model_name and model_id from the URI path.
    PATH_REGEXP = %r(\A/([A-Z][^/]+)/?([0-9]+)?\z)

    def check_host(host)
      validate_component(host)
      super
    end

    def check_path(path)
      validate_component(path)
      set_model_components(path, true)
    end

    def check_scheme(scheme)
      if scheme == "plateid"
        super
      else
        raise URI::BadURIError, "Not a plateid:// URI scheme: #{inspect}"
      end
    end

    def set_model_components(path, validate = false)
      _, base_class, id = path.match(PATH_REGEXP).to_a
      id = CGI.unescape(id) if id

      if validate
        validate_mapping(host, base_class)
        validate_component(host)
        validate_component(base_class)
      end

      @host = host
      @base_class = base_class
      @id = id
    end

    def validate_component(component)
      return component unless component.nil? || component.empty?

      raise URI::InvalidComponentError,
        "Expected a URI like plateid://Group/Class/1234: #{inspect}"
    end

    def validate_mapping(host, base_class)
      reverse_map = MAPPING.values.detect do |map|
        map[:host] == host && map[:base_class] == base_class
      end
      return if reverse_map

      raise URI::InvalidComponentError,
        "Not a valid PlateID URI: #{inspect}"
    end
  end

  @@schemes["PlateID"] = PlateID
end
