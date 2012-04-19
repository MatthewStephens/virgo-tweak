require 'marc'

class UVA::VirgoMarcRecord
  
  attr_reader :record
  
  def initialize(marc, format=:raw)
    marc=marc.to_s
    if format==:xml
      reader = MARC::XMLReader.new(StringIO.new(marc))
      @record=reader.detect{|r|true}
    else
      @record = MARC::Record.new_from_marc(marc, :forgiving=>true)
	  return(@record)
    end
  end
  
  def available?
    self['926']['f'].to_i > 0 if @record and @record['926']
  end
  
  def internet_url
    subfields_of('856', ['u'])
  end
  
  # library of congress control number - MARC 010-a
  # these often have leading spaces
  # also, some appear to have cruft after the number, so take the number before a space
  # example:  <subfield code="a">   63009960 //r64</subfield>
  def lc_control_number
    vals = subfields_of('010', ['a'])||[]
    nums = []
    vals.each do |val|
      val.strip!
      nums << val.split(" ")[0]
    end
    nums
  end
  
  # oclc number - MARC 035-a, if that value begins with OCoLC
  # strip OCoLC to get the actual number
  # example: <subfield code="a">(OCoLC)00328354</subfield>
  def oclc_number
    vals = subfields_of('035', ['a'])||[]
    oclc_numbers = []
    identifier = '(OCoLC)'
    vals.each do |val|
      if val =~ /#{identifier}/
        oclc_numbers << val.delete(identifier)
      end
    end
    oclc_numbers
  end
  
  # 245a = Title
  def title
    if(self['245'] && self['245']['a'])
      (self['245']['a']).strip.chomp("/")
    end
  end
  
  # 245b = "Remainder of title" ,i.e., subtitle
  def subtitle
    if(self['245'] && self['245']['b'])
      (self['245']['b']).strip.chomp("/")
    end
  end
  
  # 245c = "Statement of responsibility, etc.", i.e., the author as it appears on the item
  def responsibility_statement
    if (self['245'] && self['245']['c'])
      self['245']['c']   
    else if (self['100'] && (self['100']['a'] || self['100']['b'] || self['100']['c']))
      subfields_of('100', ['a', 'b', 'c']).join(' ')  
    else if (self['110'] && (self['110']['a'] || self['110']['b']))
      subfields_of('110', ['a', 'b']).join(' ')      
    end
    end
    end
  end
  
  # 245h = "Medium" e.g. [videorecording]
  def medium
    if (self['245'] && self['245']['h'])
      (self['245']['h']).strip.chomp("/")
    end
  end
    
  # 245n & 245p = "Number of part/section of a work"
  def part
    if (self['245'] && (self['245']['n'] || self['245']['p']))
      p = ""
      p += self['245']['n'] unless self['245']['n'].nil?
      p += " "
      p += self['245']['p'] unless self['245']['p'].nil?
      p
    end
  end
  
  # 245f = "Inclusive dates",date_coverage
  def date_coverage
    if (self['245'] && self['245']['f'])
      (self['245']['f']).strip.chomp("\n")
    end
  end
  
  # 245g = "Bulk dates"
  def date_bulk_coverage
    if (self['245'] && self['245']['g'])
      self['245']['g']
    end
  end
  
  # 245k = "form" 
  def form
    if (self['245'] && self['245']['k'])
      self['245']['k']
    end
  end
  
  def isbn(verbose=false)
    if verbose
      vals = subfields_of('020', ['a', 'z', '6', '8'])
      vals.each do |val|
        val.strip!
        val.chomp!(":")
        val.strip!
      end
      vals
    else
      subfields_of('020', nil, /[0-9]+/)
    end
  end
  
  def issn
    subfields_of('022', nil, /[0-9]+/)
  end
  
  # this is terrible... yes, I did it.
  def series_subfields
    values = subfields_of('410', ['a']) + subfields_of('411', ['a']) + subfields_of('440', ['a'])
    values.map{|v|v.chomp(",")}
  end
  
  def edition
    subfields_of('250', nil, /.*/, ['6'])
  end
  
  def publication_statement
    publication_statement=[]
    a = subfields_of('260', nil, /.*/, ['6'])
    b = linked_subfields_of('260', nil, /.*/, ['6'])
    publication_statement << a unless a.nil?
    publication_statement << b unless b.nil?
    publication_statement.delete_if {|x| x.empty? }
  end
  
  def subject_subfields
    subfields_of('610') + subfields_of('650')
  end
  
  #return an array of label numbers
  def label_no
    if self['028'].nil?
      return []
    end
    a = []
        
    self.fields.collect do |field|
      if field.tag=='028' and ! field.value.blank?
        string = ''
        field.subfields.collect do |subfield|
          string += subfield.value + ' '
        end
        string = string.strip
        a << string
      end
    end
    a
  end
  
  def main_entry_personal_name
    subfields_of('100','a').map {|name| name.chomp(",").chomp(".") }
  end
  
  def main_entry_corporate_body
    subfields_of('110')
  end
  
  def main_entry_conference
    subfields_of('111')
  end
  
  # 130 = Main entry Uniform title - http://www.loc.gov/marc/bibliographic/bd130.html
  # 240a = Uniform title for an item when the bibliographic description is entered under 
  # a main entry field that contains a personal (field 100), corporate (110), or meeting (111) name.
  def uniform_title
    uniform_titles = []
    a = subfields_of('130', ['a', 'f', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's']).join(' ')
    b = subfields_of('240', ['a', 'f', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's']).join(' ')
    uniform_titles << a
    uniform_titles << b unless b.nil?
    uniform_titles.delete_if {|x| x.empty? }  
  end
  
  def abbreviated_title
    subfields_of('210')
  end
  
  def title_statement_of_responsibility
    subfields_of('210')
  end
  
  def variant_title
    subfields_of('246', nil, /.*/, ['6'])
  end
  
  def cartographic_math_data
    subfields_of('255')
  end
  
  def physical_description
    subfields_of('300')
  end
  
  def journal_frequency
    subfields_of('310').join(' ')
  end
  
  def organization_and_arrangement
    subfields_of('351')
  end
  
  def publication_history
    subfields_of('362')
  end
  
  def series_statement
    series_statement = []
    a = subfields_of('440').join(' ')
    b = subfields_of('490', nil, /.*/, ['6']).join(' ')
    c = subfields_of('800').join(' ')
    d = subfields_of('830', nil, /.*/, ['6']).join(' ')
    series_statement << a unless a.nil?
    series_statement << b unless b.nil?
    series_statement << c unless c.nil?
    series_statement << d unless d.nil?
    series_statement.delete_if { |x| x.empty? }  
  end
  
  def note
    subfields_of('500', nil, /.*/, ['6'])
  end
  
  def with_note
    subfields_of('501')
  end
  
  def bibliographical_references_note
    subfields_of('504')
  end
  
  def cited_in
    subfields_of('510', nil, /.*/, ['6']).join(' ')
  end
  
  def target_audience
    subfields_of('521')
  end
  
  def other_forms
    subfields_of('530')
  end
  
  def location_of_originals
    subfields_of('535')
  end
  
  def technical_details
    subfields_of('538')
  end
  
  def performers
    unless self['511'] 
      return [] 
    end
    performers=[]
    a = subfields_of('511', nil, /.*/, ['6'])
    b = linked_subfields_of('511', nil, /.*/, ['6'])
    performers << a unless a.nil?
    performers << b unless b.nil?
    performers.delete_if {|x| x.empty? }
    
    #subfields_of('511')
    #a = self['511'].value.split(';')
    #b = []
    #a.each do |performer|
     # b << performer.squeeze(" ").strip
    #end
    #return b
  end
  
  #track_list and contents_note both return an array of the items listed in a 505 field. We want to be able to 
  #refer to a contents_note for books, but a track_list for musical recordings, but we want to stay DRY and only
  #define this behavior once, so contents_note just calls the track_list method.
  def contents_note
    self.track_list
  end
  
  # track_list should return an Array of track lists, or an empty Array if there is no track listing
  # track lists are stored in so many different subfields and formats, but the consistent part is that they
  # are separated by "--".  So, cycle through all of '505' and then split by "--"
  def track_list
    return [] if self['505'].nil?
    
    list = []
    
    string = ''
    
    fields = record.find_all {|f| f.tag == '505'}
    fields.each do |field|
      field.subfields.each do |subfield|
        val = subfield.value
        string += val + " "
      end
      string += "--"
    end
    
    tracks = string.split('--')
    tracks.each do |track|
      val = track.squeeze(" ").strip
      val.sub!(/\.$/, "")
      list << val 
    end

    list    
  end
  
  def access_restriction
    subfields_of('506')
  end
  
  def recording_information
    subfields_of('518')
  end
  
  def credits
    credits=[]
    a = subfields_of('508', nil, /.*/, ['6'])
    b = linked_subfields_of('508', nil, /.*/, ['6'])
    credits << a unless a.nil?
    credits << b unless b.nil?
    credits.delete_if {|x| x.empty? }
  end
  
  def plot_summary
    plot_summary=[]
    a = subfields_of('520', nil, /.*/, ['6'])
    b = linked_subfields_of('520', nil, /.*/, ['6'])
    plot_summary << a unless a.nil?
    plot_summary << b unless b.nil?
    plot_summary.delete_if {|x| x.empty? }
  end
  
  def citation_note
    subfields_of('524')
  end
  
  def reproduction_note
    subfields_of('533').join(' ')
  end
  
  def original_version
    subfields_of('534', ['p', 't', 'c', 'n', 'l', 'e']).join(' ')
  end
  
  def terms_of_use
    subfields_of('540')
  end
  
  def biographical_note
    subfields_of('545')
  end
  
  def language
    subfields_of('546')
  end
  
  def finding_aid_note
    subfields_of('555')
  end
  
  def title_history_note
    subfields_of('580', 'a')
  end
  
  def local_note
    local_note=[]
    a = subfields_of('590', nil, /.*/, ['6'])
    b = linked_subfields_of('590', nil, /.*/, ['6'])
    local_note << a unless a.nil?
    local_note << b unless b.nil?
    local_note.delete_if {|x| x.empty? }
  end
  
  def personal_name_as_subject
    subfields_of('600')
  end
  
  def corporate_name_as_subject
    subfields_of('610')
  end
  
  def conference_as_subject
    subfields_of('611')
  end
  
  def title_as_subject
    subfields_of('630')
  end
  
  def lc_subject_heading
    subfields_of('650')
  end
  
  def lc_geographical_subject_heading
    subfields_of('651')
  end
  
  def lc_genre_subject_heading
    subfields_of('655')
  end
  
  def local_subject_heading
    subfields_of('690')
  end

  def get_personal_name(part, field)
    role = ''
    if part['e']
      role = part['e']
    elsif part['4'] and get_role(part['4'])
      role = get_role(part['4'])
    end
    role = " (" + role.tr('.', '').capitalize + ")" unless role.blank?
    name = ''
    name = part['a'].tr('.', '') unless part['a'].nil?
    if (field == '700')
      name += ' ' + part['q'] unless part['q'].nil?
    end
    name += ' ' + part['b'].tr('.','') unless part['b'].nil?
    if (field == '111')
      name += ' ' + part['n'] unless part['n'].nil?
    end
    name += ' ' + part['d'] unless part['d'].nil?
    if (field == '711' or field == '111' or field == '100' or field == '700')
      name += ' ' + part['c'] unless part['c'].nil?
    end
    name += role
    name.strip!
    name
  end
  
  def get_title_parts(part)
    title = ''
    subfields = ['t', 'm', 'n', 'p', 'r', 'k', 'f', 'l', 'o', 's']
    subfields.each do |subfield|
      title += ' ' + part[subfield] unless part[subfield].nil?
    end 
    title.strip!
    title
  end
  
  #get all the proper name added entries and their role names
  def related_names
    related_names = []
    name = ''    
    fields = ['100', '110', '111', '700', '710', '711']
    fields.each do |field|
      name_parts = self.find_all {|f| f.tag == field}
      name_parts.each do |part|
        name = get_personal_name(part, field)
        related_names << name
        if field == '100'
          uniform_title_codes = ['a', 'k', 'm', 'n', 'p', 'r', 't', 'f', 'l', 'o', 's']  
          name_plus_title = name + ' ' + subfields_of('240', uniform_title_codes).join(' ')
          name_plus_title.strip!    
          related_names << name_plus_title
        end
        if field == '700'
          related_names << (name + ' ' + get_title_parts(part)).strip
        end
      end
    end
    return related_names.uniq
  end
  
  def related_title
    subfields_of('730').join(' ') + subfields_of('740').join(' ')
  end
  
  def previous_title
    extract_from_field_with_indicator('780', '0', ['a', 'b', 't', 'x']).join(' ')
  end
  
  def later_title
    extract_from_field_with_indicator('785', '0', ['a', 'b', 't', 'x']).join(' ')
  end
  
  def located_in
    located_in = []
    located_in << subfields_of('773', ['a', 's', 't', 'b', 'd', 'g', 'h']).join(' ')
    located_in.delete_if {|x| x.empty? } 
  end

  def url
    subfields_of('856')
  end
  
  # return an array of hashes, each of which contains a label and a value
  def related_resources
    return process_856(2) + process_856(1) + process_856(7) + process_856(' ', 7)
  end
  
  # return an array of hashes, each of which contains a label and a value
  # an indicator2 of 0 in an 856 field means that there is an online version of this resource
  def online_versions
    return process_856(0) + process_856(" ")
  end
  
  def textual_holdings
    holdings = []
    fields = record.find_all {|f| f.tag == '866' || f.tag == '868'}
    fields.each do |field|
      line = ""
      field.subfields.each do |subfield|
        line += subfield.value.strip if subfield.code == 'a'
        line += " " + subfield.value.strip if subfield.code == 'x'
        line += " " + subfield.value.strip if subfield.code == 'z'
        line += " " + subfield.value.strip if subfield.code == '2'
        line += " " + subfield.value.strip if subfield.code == '6'
      end
      holdings << line
    end
    holdings
  end
  
  def location_notes
    subfields_of('946')
  end
  
  # This methods returns a single dimensional array of values for subfields (it also removes blank values)
  # if subs is specified, only the matching subfields are returned
  # if subs is nil, the all subfields are returned
  # the value_regx can be used to match the value of the subfield
  #not_subs is for listing subfields that should not be returned, if nil no restriction will be placed
  #
  # =example: subfields_of '045', [:a]
  #
  # =parameters
  # field_name - '045' etc.
  # subs - [:a, :b] etc.
  # value_regx - a Regexp
  #not_subs - [:a, :b] etc.
  def subfields_of(field_name, subs=nil, value_regx=/.*/, not_subs=nil)
    subs ||= []
    not_subs ||= []
    self.fields.collect do |field|
      if field.tag==field_name and ! field.value.blank?
        field.subfields.collect do |subfield|
          next if (! subs.empty? and ! subs.include?(subfield.code)) or (not_subs.include?(subfield.code))
          v=subfield.value.match(value_regx).to_s
          v.empty? ? nil : v
          v
        end
      end
    end.flatten.uniq.reject{|v|v.to_s.blank?}
  end
  
  # This methods returns a single dimensional array of values for subfields (it also removes blank values)
   # if subs is specified, only the matching subfields are returned
   # if subs is nil, the all subfields are returned
   # the value_regx can be used to match the value of the subfield
   #not_subs is for listing subfields that should not be returned, if nil no restriction will be placed
   #
   # =example: linked_subfields_of '045', [:a]
   #
   # =parameters
   # field_name - '045' etc.
   # subs - [:a, :b] etc.
   # value_regx - a Regexp
   #not_subs - [:a, :b] etc.
   def linked_subfields_of(field_name, subs=nil, value_regx=/.*/,not_subs=nil)
     subs ||= []
     not_subs ||= []
     result = []
     self.fields.each do |field|
       if field.tag=='880' and ! field.value.blank?
         field.subfields.each do |sf|
           if (sf.code=='6' and sf.value.starts_with?(field_name))
             result << field.subfields.collect do |subfield|
               next if (! subs.empty? and !subs.include?(subfield.code)) or (not_subs.include?(subfield.code))
               v=subfield.value.match(value_regx).to_s
               v.empty? ? nil : v
               v
             end
           end
         end
       end
     end
     result.flatten.uniq.reject{|v|v.to_s.blank?}
   end
   
  
  protected
    
    #
    # Pass all methods not present here to the @record instance (MARC)
    #
    def method_missing(*args, &block)
      @record.send *args, &block
    end
    
    # 856 fields are url fields, but they hold various kinds of urls
    # what kind of url it is is indicated in the indicator2
    # see a full specification of this at http://www.loc.gov/marc/bibliographic/bd856.html
    # given a value for indicator2, return an array of hashes, each of which contains a label and a value
    # 0 = an online version of the item
    # 1 = some version of the item, e.g., a table of contents or a sample chapter
    # 2 = a related resource, e.g., an author bio
    def process_856(indicator2, indicator1 = nil)
      # technically, indicator2 can have values other than 0, 1,and 2, but those are the only ones we're prepared to deal with 
      # if indicator2 isn't among the valid indicator2 values, just return nil and don't bother with the rest of the method
      indicator2 = indicator2.to_s
      indicator1 = indicator1.to_s if !indicator1.nil?
      valid_indicator2_values = [" ","0","1","2","7"]
      unless valid_indicator2_values.include? indicator2 
        return Array.new
      end
      vals = extract_from_856('4', indicator2)
      return vals unless vals.empty?      
      vals = extract_from_856(' ', indicator2)
      return vals unless vals.empty?
      vals = extract_from_856(indicator1, indicator2)
      vals
    end
    
    def extract_from_856(indicator1, indicator2)
       rr_marcfields = self.fields.select do |x|
          x.tag == '856' and x.indicator1 == indicator1 and x.indicator2 == indicator2
        end
        # create an array of hashes
        result = []
        rr_marcfields.collect do |y|
          h = {}
          # for each subfield, "inject" a label and value into a new hash (h) - returns a single hash
          subfield_label_3 = y.subfields.select{ |subfield| subfield.code == "3"}.first.value rescue ""
          subfield_label_z = y.subfields.select{ |subfield| subfield.code == "z"}.first.value rescue ""
          subfield_value = y.subfields.select{ |subfield| subfield.code == "u"}.first.value rescue ""
          h["label"] = (subfield_label_3 + " " + subfield_label_z).strip.sub(/:$/, '')
          h["value"] = subfield_value
          h["label"] = h["value"] if h["label"].blank?
    		  result << h
        end
        result
     end
     
    def extract_from_field_with_indicator(field_number, indicator1,  subfields)
      vals = []
      fields = self.fields.select do |x|
        x.tag == field_number and x.indicator1 == indicator1
      end
      fields.each do |field|
        field.subfields.each do |subfield|
          vals << subfield.value if subfields.include?(subfield.code)
        end
      end
      vals
    end
    
    def get_role(r)
      role_hash = {
        'acp'=>'Art copyist',
        'act'=>'Actor',
        'adp'=>'Adapter',
        'aft'=>'Author of afterword, colophon, etc.',
        'anl'=>'Analyst',
        'anm'=>'Animator',
        'ann'=>'Annotator',
        'ant'=>'Bibliographic antecedent',
        'app'=>'Applicant',
        'aqt'=>'Author in quotations or text abstracts',
        'arc'=>'Architect',
        'ard'=>'Artistic director',
        'arr'=>'Arranger',
        'art'=>'Artist',
        'asg'=>'Assignee',
        'asn'=>'Associated name',
        'att'=>'Attributed name',
        'auc'=>'Auctioneer',
        'aud'=>'Author of dialog',
        'aui'=>'Author of introduction',
        'aus'=>'Author of screenplay',
        'aut'=>'Author',
        'bdd'=>'Binding designer',
        'bjd'=>'Bookjacket designer',
        'bkd'=>'Book designer',
        'bkp'=>'Book producer',
        'bnd'=>'Binder',
        'bpd'=>'Bookplate designer',
        'bsl'=>'Bookseller',
        'ccp'=>'Conceptor',
        'chr'=>'Choreographer',
        'clb'=>'Collaborator',
        'cli'=>'Client',
        'cll'=>'Calligrapher',
        'clt'=>'Collotyper',
        'cmm'=>'Commentator',
        'cmp'=>'Composer',
        'cmt'=>'Compositor',
        'cng'=>'Cinematographer',
        'cnd'=>'Conductor',
        'cns'=>'Censor',
        'coe'=>'Contestant-appellee',
        'col'=>'Collector',
        'com'=>'Compiler',
        'cos'=>'Contestant',
        'cot'=>'Contestant-appellant',
        'cov'=>'Cover designer',
        'cpc'=>'Copyright claimant',
        'cpe'=>'Complainant-appellee',
        'cph'=>'Copyright holder',
        'cpl'=>'Complainant',
        'cpt'=>'Complainant-appellant',
        'cre'=>'Creator',
        'crp'=>'Correspondent',
        'crr'=>'Corrector',
        'csl'=>'Consultant',
        'csp'=>'Consultant to a project',
        'cst'=>'Costume designer',
        'ctb'=>'Contributor',
        'cte'=>'Contestee-appellee',
        'ctg'=>'Cartographer',
        'ctr'=>'Contractor',
        'cts'=>'Contestee',
        'ctt'=>'Contestee-appellant',
        'cur'=>'Curator',
        'cwt'=>'Commentator for written text',
        'dfd'=>'Defendant',
        'dfe'=>'Defendant-appellee',
        'dft'=>'Defendant-appellant',
        'dgg'=>'Degree grantor',
        'dis'=>'Dissertant',
        'dln'=>'Delineator',
        'dnc'=>'Dancer',
        'dnr'=>'Donor',
        'dpc'=>'Depicted',
        'dpt'=>'Depositor',
        'drm'=>'Draftsman',
        'drt'=>'Director',
        'dsr'=>'Designer',
        'dst'=>'Distributor',
        'dtc'=>'Data contributor',
        'dte'=>'Dedicatee',
        'dtm'=>'Data manager',
        'dto'=>'Dedicator',
        'dub'=>'Dubious author',
        'edt'=>'Editor',
        'egr'=>'Engraver',
        'elg'=>'Electrician',
        'elt'=>'Electrotyper',
        'eng'=>'Engineer',
        'etr'=>'Etcher',
        'exp'=>'Expert',
        'fac'=>'Facsimilist',
        'fld'=>'Field director',
        'flm'=>'Film editor',
        'fmo'=>'Former owner',
        'fpy'=>'First party',
        'fnd'=>'Funder',
        'frg'=>'Forger',
        'gis'=>'Geographic information specialist',
        'grt'=>'Graphic technician',
        'hnr'=>'Honoree',
        'hst'=>'Host',
        'ill'=>'Illustrator',
        'ilu'=>'Illuminator',
        'ins'=>'Inscriber',
        'inv'=>'Inventor',
        'itr'=>'Instrumentalist',
        'ive'=>'Interviewee',
        'ivr'=>'Interviewer',
        'lbr'=>'Laboratory',
        'lbt'=>'Librettist',
        'ldr'=>'Laboratory director',
        'led'=>'Lead',
        'lee'=>'Libelee-appellee',
        'lel'=>'Libelee',
        'len'=>'Lender',
        'let'=>'Libelee-appellant',
        'lgd'=>'Lighting designer',
        'lie'=>'Libelant-appellee',
        'lil'=>'Libelant',
        'lit'=>'Libelant-appellant',
        'lsa'=>'Landscape architect',
        'lse'=>'Licensee',
        'lso'=>'Licensor',
        'ltg'=>'Lithographer',
        'lyr'=>'Lyricist',
        'mcp'=>'Music copyist',
        'mfr'=>'Manufacturer',
        'mdc'=>'Metadata contact',
        'mod'=>'Moderator',
        'mon'=>'Monitor',
        'mrk'=>'Markup editor',
        'msd'=>'Musical director',
        'mte'=>'Metal-engraver',
        'mus'=>'Musician',
        'nrt'=>'Narrator',
        'opn'=>'Opponent',
        'org'=>'Originator',
        'orm'=>'Organizer of meeting',
        'oth'=>'Other',
        'own'=>'Owner',
        'pat'=>'Patron',
        'pbd'=>'Publishing director',
        'pbl'=>'Publisher',
        'pdr'=>'Project director',
        'pfr'=>'Proofreader',
        'pht'=>'Photographer',
        'plt'=>'Platemaker',
        'pma'=>'Permitting agency',
        'pmn'=>'Production manager',
        'pop'=>'Printer of plates',
        'ppm'=>'Papermaker',
        'ppt'=>'Puppeteer',
        'prc'=>'Process contact',
        'prd'=>'Production personnel',
        'prf'=>'Performer',
        'prg'=>'Programmer',
        'prm'=>'Printmaker',
        'pro'=>'Producer',
        'prt'=>'Printer',
        'pta'=>'Patent applicant',
        'pte'=>'Plaintiff-appellee',
        'ptf'=>'Plaintiff',
        'pth'=>'Patent holder',
        'ptt'=>'Plaintiff-appellant',
        'rbr'=>'Rubricator',
        'rce'=>'Recording engineer',
        'rcp'=>'Recipient',
        'red'=>'Redactor',
        'ren'=>'Renderer',
        'res'=>'Researcher',
        'rev'=>'Reviewer',
        'rps'=>'Repository',
        'rpt'=>'Reporter',
        'rpy'=>'Responsible party',
        'rse'=>'Respondent-appellee',
        'rsg'=>'Restager',
        'rsp'=>'Respondent',
        'rst'=>'Respondent-appellant',
        'rth'=>'Research team head',
        'rtm'=>'Research team member',
        'sad'=>'Scientific advisor',
        'sce'=>'Scenarist',
        'scl'=>'Sculptor',
        'scr'=>'Scribe',
        'sds'=>'Sound designer',
        'sec'=>'Secretary',
        'sgn'=>'Signer',
        'sht'=>'Supporting host',
        'sng'=>'Singer',
        'spk'=>'Speaker',
        'spn'=>'Sponsor',
        'spy'=>'Second party',
        'srv'=>'Surveyor',
        'std'=>'Set designer',
        'stl'=>'Storyteller',
        'stm'=>'Stage manager',
        'stn'=>'Standards body',
        'str'=>'Stereotyper',
        'tcd'=>'Technical director',
        'tch'=>'Teacher',
        'ths'=>'Thesis advisor',
        'trc'=>'Transcriber',
        'trl'=>'Translator',
        'tyd'=>'Type designer',
        'tyg'=>'Typographer',
        'vdg'=>'Videographer',
        'voc'=>'Vocalist',
        'wam'=>'Writer of accompanying material',
        'wdc'=>'Woodcutter',
        'wde'=>'Wood-engraver',
        'wit'=>'Witness'
      }
      return role_hash[r]
    end
    
end
