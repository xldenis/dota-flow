class Settings
  def initialize(file)
    begin
      @settings = YAML.load_file(file)
    rescue
      @settings = {}
    end
  end

  def [](key)
    @settings[key] || ENV[key]
  end
end