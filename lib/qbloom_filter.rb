require "bloom_filter/version"
require "bitset"
require 'digest/md5'

module BloomFilter
  PRIME = 100_000_000_003
  MAX_HASH_PARAM = 1000
  OUT_OF_RANGE = "Position is out of range"
  DIFFERENT_INITIAL_PARAMS = "Bloom filters have different initial params"

  class Filter
    attr_reader :count, :capacity, :probability

    def initialize(capacity = 100, probability = 0.01)
      # amount of inserted elements
      @count = 0

      # params ob filter, are used for comparison with params of other bloom filters
      @capacity = capacity
      @probability = probability

      #number of bits in the array
      @m = (-(capacity * Math.log(probability)) / (Math.log(2) ** 2)).ceil

      @bitset = Bitset.new(@m)

      #number of hash functions that minimizes the probability of false positives
      @k = (Math.log(2) * (@m / capacity)).ceil
    end

    def add(value)
      x = get_hash(value)
      was_inserted = true
      @k.times do |i|
        a, b = get_hash_params(i)
        position = get_position(a, b, x)
        was_inserted = false unless self.get_bit(position)
        self.set_bit(position)
      end
      @count += 1 unless was_inserted
      value
    end

    def contains?(value)
      x = get_hash(value)
      result = true
      @k.times do |i|
        a, b = get_hash_params(i)
        result = false unless self.get_bit(get_position(a, b, x))
      end

      result
    end
    alias :includes? :contains?

    def bit_size
      @m
    end

    def get_bit(position)
      valid_position?(position)
      @bitset[position]
    end

    def set_bit(position)
      valid_position?(position)
      @bitset[position] = true
    end

    def clear_bit(position)
      valid_position?(position)
      @bitset[position] = false
    end

    def union_with(bloom_filter)
      same_params?(bloom_filter)

      @m.times do |i|
        @bitset[i] = self.get_bit(i) || bloom_filter.get_bit(i)
      end
    end

    def intersect_with(bloom_filter)
      same_params?(bloom_filter)

      @m.times do |i|
        @bitset[i] = self.get_bit(i) && bloom_filter.get_bit(i)
      end
    end

    private

    def get_position(a, b, val)
      ((a * val + b) % PRIME) % @m
    end

    def get_hash(value)
      Digest::MD5.hexdigest(value.to_s).to_i(16)
    end

    def valid_position?(position)
      raise OUT_OF_RANGE if position >= @m
      true
    end

    def same_params?(bf)
      raise DIFFERENT_INITIAL_PARAMS if self.class != bf.class || bf.capacity != @capacity || bf.probability != @probability
      true
    end

    def get_hash_params(i)
      return 2*i + 1, 2*i + 2
    end
  end
end
