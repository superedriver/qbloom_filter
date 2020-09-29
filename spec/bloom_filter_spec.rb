require './lib/qbloom_filter'

RSpec.describe BloomFilter::Filter do
  describe "hash functions size and bitset size" do
    it "default values" do
      bf = BloomFilter::Filter.new
      expect(bf.instance_variable_get(:@m)).to eq(959)
      expect(bf.instance_variable_get(:@k)).to eq(7)
    end

    it "not default values" do
      bf = BloomFilter::Filter.new(1000, 0.001)
      expect(bf.instance_variable_get(:@m)).to eq(14_378)
      expect(bf.instance_variable_get(:@k)).to eq(10)
    end
  end

  describe "adding values" do
    it "before inserting value" do
      value = 'test'
      bf = BloomFilter::Filter.new
      expect(bf.includes?(value)).to eq(false)
      expect(bf.count).to eq(0)
    end

    it "after inserting value" do
      value = 'test'
      bf = BloomFilter::Filter.new
      bf.add(value)
      expect(bf.includes?(value)).to eq(true)
      expect(bf.count).to eq(1)
    end

    it "inserting the same value" do
      value = 'test'
      bf = BloomFilter::Filter.new
      bf.add(value)
      bf.add(value)
      expect(bf.includes?(value)).to eq(true)
      expect(bf.count).to eq(1)
    end
  end

  describe "if value presents" do
    it "does not present" do
      value = 'test'
      bf = BloomFilter::Filter.new
      expect(bf.includes?(value)).to eq(false)
    end

    it "presents" do
      value = 'test'
      bf = BloomFilter::Filter.new
      bf.add(value)
      expect(bf.includes?(value)).to eq(true)
    end
  end

  describe "count" do
    it "empty bitset" do
      bf = BloomFilter::Filter.new
      expect(bf.count).to eq(0)
    end

    it "5 insertions" do
      bf = BloomFilter::Filter.new
      bf.add('test1')
      bf.add('test2')
      bf.add('test3')
      bf.add('test4')
      bf.add('test5')
      expect(bf.count).to eq(5)
    end
  end

  describe "initial params" do
    it "default params" do
      bf = BloomFilter::Filter.new
      expect(bf.capacity).to eq(100)
      expect(bf.probability).to eq(0.01)
    end

    it "capacity: 1000, probability: 0.001" do
      bf = BloomFilter::Filter.new(1000, 0.001)
      expect(bf.capacity).to eq(1000)
      expect(bf.probability).to eq(0.001)
    end
  end

  describe "bit_size" do
    it "capacity: 100, probability: 0.01" do
      bf = BloomFilter::Filter.new(100, 0.01)
      expect(bf.bit_size).to eq(959)
    end

    it "capacity: 1000, probability: 0.001" do
      bf = BloomFilter::Filter.new(1000, 0.001)
      expect(bf.bit_size).to eq(14378)
    end
  end

  describe "get_bit set_bit clear_bit" do
    it "get set clear 0" do
      pos = 0
      bf = BloomFilter::Filter.new(100, 0.01)
      expect(bf.get_bit(pos)).to eq(false)
      bf.set_bit(pos)
      expect(bf.get_bit(pos)).to eq(true)
      bf.clear_bit(pos)
      expect(bf.get_bit(pos)).to eq(false)
    end

    it "get set clear 10" do
      pos = 10
      bf = BloomFilter::Filter.new(100, 0.01)
      expect(bf.get_bit(pos)).to eq(false)
      bf.set_bit(pos)
      expect(bf.get_bit(pos)).to eq(true)
      bf.clear_bit(pos)
      expect(bf.get_bit(pos)).to eq(false)
    end
  end

  describe "out of range error" do
    it "get_bit" do
      bf = BloomFilter::Filter.new(10, 0.1)
      pos = bf.bit_size + 1
      expect{ bf.get_bit(pos) }.to raise_error(BloomFilter::OUT_OF_RANGE)
    end

    it "set_bit" do
      bf = BloomFilter::Filter.new(10, 0.1)
      pos = bf.bit_size + 1
      expect{ bf.set_bit(pos) }.to raise_error(BloomFilter::OUT_OF_RANGE)
    end

    it "clear_bit" do
      bf = BloomFilter::Filter.new(10, 0.1)
      pos = bf.bit_size + 1
      expect{ bf.clear_bit(pos) }.to raise_error(BloomFilter::OUT_OF_RANGE)
    end
  end

  describe "different instances with the same params" do
    it "bit_size should be the same" do
      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)
      expect(bf1.bit_size).to eq(bf2.bit_size)
    end

    it "bites should be the same after insertions" do
      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)
      bf1.add('test')
      bf2.add('test')
      bf1.add('test1')
      bf2.add('test1')
      bf1.bit_size.times { |i| expect(bf1.get_bit(i)).to eq(bf2.get_bit(i)) }
    end
  end

  describe "union_with" do
    it "before union" do
      val1 = 'Kolyan'
      val2 = 'Vovan'
      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)

      bf1.add(val1)
      bf2.add(val2)

      expect(bf1.includes?(val1)).to eq(true)
      expect(bf1.includes?(val2)).to eq(false)

      expect(bf2.includes?(val1)).to eq(false)
      expect(bf2.includes?(val2)).to eq(true)
    end

    it "after union" do
      val1 = 'Kolyan'
      val2 = 'Vovan'
      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)
      bf1.add(val1)
      bf2.add(val2)

      bf1.union_with(bf2)

      expect(bf1.includes?(val1)).to eq(true)
      expect(bf1.includes?(val2)).to eq(true)

      expect(bf2.includes?(val1)).to eq(false)
      expect(bf2.includes?(val2)).to eq(true)
    end

    it "error union_with different capacity" do
      bf1 = BloomFilter::Filter.new(100, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)

      expect{ bf1.union_with(bf2) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end

    it "error union_with different probability" do
      bf1 = BloomFilter::Filter.new(100, 0.1)
      bf2 = BloomFilter::Filter.new(100, 0.01)

      expect{ bf1.union_with(bf2) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end

    it "error union_with different objects" do
      bf1 = BloomFilter::Filter.new(100, 0.1)

      expect{ bf1.union_with([]) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end
  end

  describe "intersect_with" do
    it "before intersection" do
      val1 = 'Kolyan'
      val2 = 'Vovan'
      val3 = 'Stasyan'

      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)

      bf1.add(val1)
      bf1.add(val3)

      bf2.add(val2)
      bf2.add(val3)

      expect(bf1.includes?(val1)).to eq(true)
      expect(bf1.includes?(val2)).to eq(false)
      expect(bf1.includes?(val3)).to eq(true)

      expect(bf2.includes?(val1)).to eq(false)
      expect(bf2.includes?(val2)).to eq(true)
      expect(bf2.includes?(val3)).to eq(true)
    end

    it "after intersection" do
      val1 = 'Kolyan'
      val2 = 'Vovan'
      val3 = 'Stasyan'

      bf1 = BloomFilter::Filter.new(10, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)

      bf1.add(val1)
      bf1.add(val3)

      bf2.add(val2)
      bf2.add(val3)

      bf1.intersect_with(bf2)

      expect(bf1.includes?(val1)).to eq(false)
      expect(bf1.includes?(val2)).to eq(false)
      expect(bf1.includes?(val3)).to eq(true)

      expect(bf2.includes?(val1)).to eq(false)
      expect(bf2.includes?(val2)).to eq(true)
      expect(bf2.includes?(val3)).to eq(true)
    end

    it "error intersect_with different capacity" do
      bf1 = BloomFilter::Filter.new(100, 0.1)
      bf2 = BloomFilter::Filter.new(10, 0.1)

      expect{ bf1.intersect_with(bf2) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end

    it "error intersect_with different probability" do
      bf1 = BloomFilter::Filter.new(100, 0.1)
      bf2 = BloomFilter::Filter.new(100, 0.01)

      expect{ bf1.intersect_with(bf2) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end

    it "error intersect_with different objects" do
      bf1 = BloomFilter::Filter.new(100, 0.1)

      expect{ bf1.intersect_with([]) }.to raise_error(BloomFilter::DIFFERENT_INITIAL_PARAMS)
    end
  end
end
