class Settings
  def initialize(file)
    @settings = YAML.load_file(file)
  end

  def [](key)
    @settings[key] || ENV[key]
  end
end