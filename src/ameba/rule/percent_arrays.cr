module Ameba::Rule
  # A rule that disallows some unwanted symbols in percent array literals.
  #
  # For example, this is usually written by mistake:
  #
  # ```
  # %i(:one, :two)
  # %w("one", "two")
  # ```
  #
  # And the expected example is:
  #
  # ```
  # %i(one two)
  # %w(one two)
  # ```
  #
  # YAML configuration example:
  #
  # ```
  # PercentArrays:
  #   Enabled: true
  #   StringArrayUnwantedSymbols: ',"'
  #   SymbolArrayUnwantedSymbols: ',:'
  # ```
  #
  struct PercentArrays < Base
    properties do
      description = "Disallows some unwanted symbols in percent array literals"
      string_array_unwanted_symbols = ",\""
      symbol_array_unwanted_symbols = ",:"
    end

    def test(source)
      error = start_token = nil

      Tokenizer.new(source).run do |token|
        case token.type
        when :STRING_ARRAY_START, :SYMBOL_ARRAY_START
          start_token = token.dup
        when :STRING
          if start_token && error.nil?
            error = array_entry_invalid?(token.value, start_token.not_nil!.raw)
          end
        when :STRING_ARRAY_END, :SYMBOL_ARRAY_END
          if error
            source.error(self, start_token.try &.location, error.not_nil!)
          end
          error = start_token = nil
        end
      end
    end

    private def array_entry_invalid?(entry, array_type)
      case array_type
      when .starts_with? "%w"
        check_array_entry entry, string_array_unwanted_symbols, "%w"
      when .starts_with? "%i"
        check_array_entry entry, symbol_array_unwanted_symbols, "%i"
      end
    end

    private def check_array_entry(entry, symbols, literal)
      return unless entry =~ /[#{symbols}]/
      "Symbols `#{symbols}` may be unwanted in #{literal} array literals"
    end
  end
end
