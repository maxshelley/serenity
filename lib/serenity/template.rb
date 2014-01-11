require 'zip'
require 'fileutils'

module Serenity
  class Template
    attr_accessor :template

    def initialize(template, output)
      FileUtils.cp(template, output)
      @template = output
    end

    def process context
      tmpfiles = []
      Zip::File.open('new_template.odt', Zip::File::CREATE) do |zipfile|
        %w(content.xml styles.xml).each do |xml_file|
          content = zipfile.read(xml_file)
          odteruby = OdtEruby.new(XmlReader.new(content))
          out = odteruby.evaluate(context)
          out.force_encoding Encoding.default_external.to_s

          tmpfiles << (file = Tempfile.new("serenity"))
          file << out
          file.close

          file
          #zipfile.replace(xml_file, file.path)
        end
      end
    end
  end
end
