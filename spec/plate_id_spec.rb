RSpec.describe PlateID do
  let(:subject) { described_class.new("plateid://Content/Element/1234") }

  describe ".create" do
    it "calls .new with result of URI::PlateID.create" do
      element = double(:element)
      expect(URI::PlateID).to receive(:create).with(element)
      expect(described_class).to receive(:new)
      described_class.create(element)
    end

    it "accepts a record and turns it into a plate_id" do
      element = double(:element, id: 4321)
      expect(URI::PlateID).to receive(:create).with(element).and_return("plateid://Content/Element/4321")
      plate_id = described_class.create(element)
      expect(plate_id).to be_kind_of(described_class)
      expect(plate_id.to_s).to eq("plateid://Content/Element/4321")
    end
  end

  describe ".parse" do
    it "returns instance of PlateID if correct string is passed" do
      expect(described_class.parse("plateid://Base/Site/1234")).to be_kind_of(described_class)
    end

    it "returns passed arg itself if it's an instance of PlateID" do
      plate_id = described_class.parse("plateid://Base/Site/1234")
      expect(described_class.parse(plate_id)).to eq(plate_id)
    end

    it "returns nil if an invalid arg is passed" do
      expect(described_class.parse("invalidstring")).to be_nil
    end
  end

  describe ".find" do
    it "calls #parse on PlateID class" do
      expect(described_class).to receive(:parse).with("plateid://Content/Post/1234")
      described_class.find("plateid://Content/Post/1234")
    end

    it "calls #find on PlateID instance" do
      expect_any_instance_of(described_class).to receive(:find)
      described_class.find("plateid://Content/Post/1234")
    end
  end

  describe "#find" do
    let(:result) { double(:result) }
    let(:plate_class) { double(:plate_class, find_by: result) }

    it "calls #find_by on #plate_class" do
      expect(subject).to receive(:plate_class).and_return(plate_class)
      expect(plate_class).to receive(:find_by).with(id: "1234").and_return(result)
      expect(subject.find).to eq(result)
    end
  end

  describe "#plate_class" do
    let(:class_string) { "Ngn::Content::Element" }
    let(:result) { double(to: nil) }

    it "calls #fetch_plate_class and calls #safe_constantize on it" do
      expect(subject).to receive(:fetch_plate_class).with(subject.uri).and_return(class_string)
      expect(class_string).to receive(:safe_constantize).and_return(result)
      subject.plate_class.to eq(result)
    end
  end

  describe "#fetch_plate_class" do
    let(:plate_id) { URI::PlateID.parse("plateid://Content/Post/9876") }

    it "returns correct Class String" do
      expect(subject.send(:fetch_plate_class, plate_id)).to eq("Ngn::Content::Post")
    end
  end

  describe "#id" do
    it "returns id from uri" do
      expect(subject.id).not_to be_nil
      expect(subject.id).to eq(subject.uri.id)
    end
  end

  describe "#id=" do
    it "sets uri id" do
      expect(subject.id).not_to be_nil
      expect(subject.id).to eq(subject.uri.id)
      subject.id = nil
      expect(subject.id).to be_nil
      expect(subject.uri.id).to be_nil
    end
  end

end
