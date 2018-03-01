class EnabledFeatures
  def self.has?(key)
    Figaro.env.send("enable_#{key}".to_sym) == 'true'
  end

  def self.not_have?(key)
    Figaro.env.send("enable_#{key}".to_sym) != 'true'
  end

end
