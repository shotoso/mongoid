# encoding: utf-8
module Mongoid
  module Indexable

    # Encapsulates behaviour around an index specification.
    #
    # @since 4.0.0
    class Specification

      # The mappings of nice Ruby-style names to the corresponding MongoDB
      # name.
      #
      # @since 4.0.0
      MAPPINGS = {
        bucket_size: :bucketSize,
        drop_dups: :dropDups,
        expire_after_seconds: :expireAfterSeconds
      }

      # @!attribute klass
      #   @return [ Class ] The class the index is defined on.
      # @!attribute key
      #   @return [ Hash ] The index key.
      # @!attribute options
      #   @return [ Hash ] The index options.
      attr_reader :klass, :key, :options

      # Is this index specification equal to another?
      #
      # @example Check equality of the specifications.
      #   specification == other
      #
      # @param [ Specification ] other The spec to compare against.
      #
      # @return [ true, false ] If the specs are equal.
      #
      # @since 4.0.0
      def ==(other)
        fields == other.fields
      end

      # Get an array of the fields, in order, that are part of the index.
      #
      # @example Get the index fields.
      #   specification.fields
      #
      # @return [ Array<Symbol> ] The names of the fields.
      #
      # @since 4.0.0
      def fields
        key.keys
      end

      # Instantiate a new index specification.
      #
      # @example Create the new specification.
      #   Specification.new(Band, { name: 1 }, background: true)
      #
      # @param [ Class ] klass The class the index is defined on.
      # @param [ Hash ] key The hash of name/direction pairs.
      # @param [ Hash ] opts the index options.
      #
      # @since 4.0.0
      def initialize(klass, key, opts = nil)
        options = opts || {}
        Validators::Options.validate(klass, key, options)
        @klass = klass
        @key = normalize_key(key)
        @options = normalize_options(options.dup)
      end

      private

      # Normalize the spec, in case aliased fields are provided.
      #
      # @api private
      #
      # @example Normalize the spec.
      #   specification.normalize_key(name: 1)
      #
      # @param [ Hash ] key The index key(s).
      #
      # @return [ Hash ] The normalized specification.
      #
      # @since 4.0.0
      def normalize_key(key)
        normalized = {}
        key.each_pair do |name, direction|
          normalized[klass.database_field_name(name).to_sym] = direction
        end
        normalized
      end

      # Normalize the index options, if any are provided.
      #
      # @api private
      #
      # @example Normalize the index options.
      #   specification.normalize_options(drop_dups: true)
      #
      # @param [ Hash ] options The index options.
      #
      # @return [ Hash ] The normalized options.
      #
      # @since 4.0.0
      def normalize_options(opts)
        options = {}
        opts.each_pair do |option, value|
          options[MAPPINGS[option] || option] = value
        end
        options
      end
    end
  end
end
