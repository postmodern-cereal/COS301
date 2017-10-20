#you can use getc on a file to read one character at a time
#
#

#declare the variables that you'll need later
$char_class #character's class
#will need to use $charclass.is_a?(Fixnum) to make sure that it's an integer
$lexeme = Array.new() #we don't have to do anything else with this because ruby doesn't care
$next_char #the next character to be read
$lex_len 	#length of the lexeme
$next_token	#number of the next token
$INPUT_FILE #the input file




#character classes
$LETTER = 0
$DIGIT = 1
$UNKNOWN = 99
$EOF = -1

#token codes
$INT_LIT 	 = 10
$IDENT 	 	 = 11
$REL_OP  	 = 12
$OR_OP   	 = 13
$AND_OP		 = 14
$REL_OP		 = 15	#for comparison and stuff
$LEFT_PAREN  = 20
$RIGHT_PAREN = 21
$BOOL_LIT 	 = 30	#true/false

#returns 0 if it's a letter, nil if not
def letter?(character)
	character =~ /[[:alpha:]]/
end

def digit?(character)
	character =~ /[[:digit:]]/
end

#spooky regex witchcraft
def space?(character)
	character =~ /[[:space:]]/
end


##Functions##
#getchar gets next char of input, puts it in nextchar, determines its class, puts that in nextclass
def get_char()
	$next_char = $INPUT_FILE.getc
	if $next_char != nil			#when you run out of file to read in rubym you get nil
		if letter?($next_char)
			$char_class = $LETTER
		elsif digit?($next_char)
			$char_class = $DIGIT
		else
			$char_class = $UNKNOWN
		end
	else
		$char_class = $EOF;
	end
end

#add the next character to the lexeme
def add_char()
	if $lex_len <= 98
		$lexeme[$lex_len++] = $next_char
		$lexeme[$lex_len] = 0
	else
		puts "Error: lexeme too long"
	end
end

#skips all of the whitespace
def get_non_blank()
	while space?($next_char)
		get_char
	end
end


def lookup(character)
	case character
	when "("
		add_char
		$next_token = $LEFT_PAREN
	when ")"
		add_char
		$next_token = $RIGHT_PAREN
	when "|"
		add_char
		$next_token = $OR_OP
	when "&"
		add_char
		$next_token = $AND_OP
	when ">", "<"
		add_char
		$next_token = $REL_OP
	else
		add_char
		$next_token = $EOF
	end
end

def lex()
	$lex_len = 0
	get_non_blank
	case $char_class
	when $LETTER
		add_char
		get_char
		while $char_class == $LETTER || $char_class == $DIGIT
			add_char
			get_char
		end
		#now that the word is fully read, we have to find ouot if it's an identifier or a boolean literal
		if $lexeme.join == "true" || $lexeme == "false"
			$next_token = $BOOL_LIT
		else
			$next_token = $IDENT
		end
	when $DIGIT
		#finish the lexeme
		add_char
		get_char
		while $char_class == $DIGIT
			add_char
			get_char
		end
		puts "Error on lexeme " + $lexeme.join + ": identifiers may not begin with digits."
		abort("Analysis terminated")
	when $UNKNOWN
			lookup($next_char)
			get_char
	when $EOF
		$next_token = $EOF
		$lexeme = ["E","O","F"]
	end
	puts "Next token is: " + $next_token + ", next lexeme is " + $lexeme.join
end


######################Main function analogue##############################
#open input file in read mode
$INPUT_FILE = File.open("input.txt", "r")
getChar()
until $next_token == $EOF do
	lex()
end



END #everything in here is done at the very end and I can just ignore it
{
    $INPUT_FILE.close
}
