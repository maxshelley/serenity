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
      Zip::File.open(@template) do |zipfile|
        %w(content.xml).each do |xml_file|
          content = zipfile.read(xml_file)
          content = content.force_encoding('UTF-8')
          odteruby = OdtEruby.new(XmlReader.new(content))
          out = odteruby.evaluate(context)
          #out.force_encoding Encoding.default_external.to_s

          tmpfiles << (file = Tempfile.new("serenity"))
          file << out
          file.close

          zipfile.replace(xml_file, file.path)
          
        end
      end

      @template

    end
  end
end
