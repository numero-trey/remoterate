require 'json'

class Remoterate
  DEFAULT_CONFIG_FILE = './remoterate.json'
  DEFAULT_OPTIONS = {
    port: 5309
  }

  def self.get_config
    config = self::DEFAULT_OPTIONS
    if File::exist? self::DEFAULT_CONFIG_FILE
      config.merge! JSON.parse(
        File.read(DEFAULT_CONFIG_FILE), 
        symbolize_names: true
      )
    end

    config
  end
end