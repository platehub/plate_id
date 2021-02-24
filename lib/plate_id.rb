require_relative "uri/plate_id"

class PlateID
  class << self

    def create(model)
      new(URI::PlateID.create(model))
    end

    def parse(plate_id)
      plate_id.is_a?(self) ? plate_id : new(plate_id)
    rescue URI::Error
      nil
    end

    def find(plate_id)
      res = parse(plate_id)
      res&.find
    end
  end

  attr_reader :uri

  def host
    uri.host
  end

  def base_class
    uri.base_class
  end

  def id
    uri.id
  end

  def id=(id)
    uri.id = id
  end

  def to_s
    uri.to_s
  end

  def initialize(plate_id)
    @uri = fetch_uri(plate_id)
  end

  def plate_class
    fetch_plate_class(uri)&.safe_constantize
  end

  def find
    return unless uri.id

    plate_class&.find_by(id: uri.id)
  end

  private

  def fetch_uri(plate_id)
    return plate_id if plate_id.is_a?(URI::PlateID)

    URI::PlateID.parse(plate_id)
  end

  def fetch_plate_class(uri)
    uri.class::MAPPING.detect do |_klass, map|
      map[:host] == uri.host && map[:base_class] == uri.base_class
    end[0]
  end
end
