%{
	type: :scrape,
	deps: [],
	examples: ["https://ARTIST.bandcamp.com/album/ALBUM", "https://ARTIST.bandcamp.com/track/TRACK"],
	regex: Regex.compile!("youtu(?:.*\/v\/|.*v\\=|\\.be\/)([A-Za-z0-9_\\-]{11})"),
	code: fn id, _options -> 
		"<iframe style=\"border: 0;\" src=\"https://bandcamp.com/EmbeddedPlayer/album=#{id}/size=large/bgcol=ffffff/linkcol=0687f5/artwork=small/transparent=true\" seamless></iframe>"
	end
}