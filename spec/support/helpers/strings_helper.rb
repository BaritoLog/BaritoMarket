module StringsHelper
  def blank_string?(value)
    if String === value
      match_value = value.strip
      ['', "\n", "\r", "\t", "\f"].any? do |empty_value|
        empty_value == match_value
      end
    end
  end
end
