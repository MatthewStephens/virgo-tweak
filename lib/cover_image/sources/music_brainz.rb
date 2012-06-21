
#mbids = Blacklight::MusicBrainz::ArtistSearch.new.find_album_ids_by_artist_and_album('paul simon', 'The rhythm of the saints')
#puts Blacklight::LastFM::AlbumInfo.new.find_by_music_brainz_id(mbids)

# /images/covers/music/catkey.u3964377.jpg
# /images/covers/books/isbn.9786256782.jpg

require 'open-uri'
require 'cgi'


module CoverImage::Sources
  
  class MusicBrainz
    
    
    def find_album_ids_by_artist_and_album(artist, album=nil)
      data=[]
      base_url = "http://musicbrainz.org/ws/1/release/?type=xml&releasetypes=Official&limit=10"
      url = base_url + "&artist=#{CGI.escape(artist)}"
      url += "&title=#{CGI.escape(album)}" unless album.to_s.empty?
      puts "
      
      MUSIC BRAINZ URL: #{url}
      
      "
      
      uri = URI.parse(url)
      Rails.logger.info "*** URL: #{uri.to_s}"
      
      begin
        doc = Nokogiri::XML(open(uri.to_s))
      rescue
        puts "
        MUSIC BRAINZ CONNECTION ERROR: #{$!}
        "
        Rails.logger.info "*** MUSIC BRAINZ ERROR: #{$!} "
        Rails.logger.info "*** URL: #{uri.to_s}"
        return data
      end
      node = doc.children[0]
      releases = doc.xpath("//*[local-name(.)='release']/@id").to_a
      releases.each do |release|
        # check values here: release.text() =~ album etc.
        data << release.text unless data.include?(release.text)
      end
      data
    end
    
  end
  
end
