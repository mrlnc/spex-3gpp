class Document < ActiveRecord::Base
  attr_accessible :name, :title, :description, :spec_serie_id, :spec_number, :spec_part

  belongs_to :spec_serie

  has_many :document_versions

  def self.parse_no(spec_no)

    m = spec_no.match(/(\d+)[\._](\d+)(?:-(\d))?(U)?/)
    raise "Unable to parse '#{spec_no}'" if not m

    res = {
        :serie => m[1].to_i,
        :number => m[2].to_i
    }

    res[:part] = m[3].to_i if not m[3].nil?
    res[:u] = true if not m[4].nil?

    res
  end

  def self.desc_to_name(desc)
    name  = if desc[:serie].to_i < 13 or desc[:u]
              "%02d.%02d" % [desc[:serie],desc[:number]]
            else
              "%02d.%03d" % [desc[:serie],desc[:number]]
            end
            
    name += "-#{desc[:part]}" if not desc[:part].nil?
    name += "U" if desc[:u]
    return name
  end

  def self.find_by_desc(desc)
    name = self.desc_to_name(desc)
    self.find_by_name(name)
  end

  def name_3gpp
    desc = parse_no
    n  = "%02d" % spec_serie.index
    n += ( spec_serie.index < 13 or desc[:u] ? "%02d" : "%03d" ) % spec_number
    n += "-#{spec_part}" if !spec_part.nil?
    n += "U" if desc[:u]
    n
  end

  def info_page_url
    "http://www.3gpp.org/ftp/Specs/html-info/#{name_3gpp}.htm"
  end

  def parse_no

    res = Document.parse_no(name)

    spec_serie = SpecSerie.find_by_index(res[:serie])
    raise "Unable to find serie for #{name}" if spec_serie.nil?

    self.spec_serie_id = spec_serie.id

    self.spec_part = res[:part] if not res[:part].nil?
    self.spec_number = res[:number]

    res
  end
end
