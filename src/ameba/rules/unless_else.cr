module Ameba::Rules
  # A rule that disallows the use of an `else` block with the `unless`.
  #
  # For example, the rule considers these valid:
  #
  # ```
  # unless something
  #   :ok
  # end
  #
  # if something
  #   :one
  # else
  #   :two
  # end
  # ```
  #
  # But it considers this one invalid as it is an `unless` with an `else`:
  #
  # ```
  # unless something
  #   :one
  # else
  #   :two
  # end
  # ```
  #
  # The solution is to swap the order of the blocks, and change the `unless` to
  # an `if`, so the previous invalid example would become this:
  #
  # ```
  # if something
  #   :two
  # else
  #   :one
  # end
  # ```
  struct UnlessElse < Rule
    def test(source)
      UnlessVisitor.new self, source
    end

    def test(source, node : Crystal::Unless)
      unless node.else.is_a?(Crystal::Nop)
        source.error self, node.location.try &.line_number,
          "Favour if over unless with else"
      end
    end
  end
end