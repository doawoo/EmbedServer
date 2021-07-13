%{
	type: :regex,
	deps: [],
	examples: ["https://www.youtube.com/watch?v=*", "https://youtu.be/*"],
	regex: Regex.compile!("youtu(?:.*\/v\/|.*v\\=|\\.be\/)([A-Za-z0-9_\\-]{11})"),
	code: fn [_, id], _options -> 
		"<iframe src=\"https://www.youtube.com/embed/#{id}\" frameborder=\"0\" allow=\"accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture;\" allowfullscreen></iframe>"
	end
}