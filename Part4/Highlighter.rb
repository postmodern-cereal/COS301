require 'rubygems'
require 'nokogiri'
require 'open-uri'

def write_to_file(file_name, to_write)
	#writes the modified html file to a new file
	new_file = File.new(file_name, "w")
	if(new_file)
		new_file.syswrite(to_write)
	end
	new_file.close
end

def get_body(doc)
	doc.root.children.each do |i|
		if i.name == "body"
			return i
		end
	end
end

def highlight(text, keyword)
	#takes the entire text and highlights all keyword instances
	h_start = "\<span style=\"background-color: blue; color: white\"\>"
	h_end = "\</span\>"
	return text.gsub /#{keyword}/, h_start + keyword + h_end
end

=begin
print "Enter a URL or input filename: "
$URL = gets.strip
print "Enter a keyword: "
$KEYWORD = gets.strip
print "Enter output filename: "
$FNAME = gets.strip
=end
$URL = "Ruby(programming_language).html"
$FNAME = "foo_2.html"
doc = Nokogiri::HTML(open($URL.to_s)) do |config|
	config.noblanks		#opens the document in a way that is easier to parse
end
doc.root.children.each do |i|
	puts i.name
end

$body = get_body(doc)
puts $body.children[1].content
$body.children.each do |i|
	#recurse
	puts i.content
end
#get the valid children and subchildren, recursively
#$body.children[1].inner_html = highlight($body.children[1].content, "Ruby")
#puts doc.to_html
#write_to_file($FNAME, doc.to_s)
