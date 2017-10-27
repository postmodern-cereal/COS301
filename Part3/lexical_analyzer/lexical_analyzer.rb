#By Noah Ransom

#writes the output to the specified file, rather than the console. I use this to make writing the appendix easier
#if the file does not exist when you run this program, it will be created for you.
$stdout.reopen("output_2.txt", "w")


#NOTE: The code for the lexical analysis is based on the code from the lexical analysis slides.
#The parsing code is also loosely based on the code from the slides, with heavy modification to fit this specific application
#I mostly borrowed the general flow of control from the slides, but I had to make major modifications to make it work.




#declare the variables that you'll need later
$char_class #character's class
#will need to use $charclass.is_a?(Fixnum) to make sure that it's an integer
$lexeme = Array.new(100) #we don't have to do anything else with this because ruby doesn't care
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
$NEG_OP		 = 16	#exclamation point
$LEFT_PAREN  = 20
$RIGHT_PAREN = 21
$BOOL_LIT 	 = 30	#true/false


def error()
	puts "Error on " + $lexeme.join + ". Parse will continue, but input is not in the language."
end

#returns 0 if it's a letter, nil if not
#the regular expressions for letter? space? and digit? were found online. I looked at a lot of different sources, and all said the same
#see https://stackoverflow.com/questions/14551256/ruby-how-to-find-out-if-a-character-is-a-letter-or-a-digit in particular
#i just used this code in my methods. I guessed that /[[:space:]]/ would work if the others did, and got lucky
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
		$lexeme[$lex_len] = $next_char
		$lex_len = $lex_len + 1
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
	when "="		#if we have one =, the next character has to be an = to be legal
		add_char
		get_char	#get the next character, so that we can test it. If it's not what we want, that's bad
		if $next_char == "="
			add_char
			$next_token = $REL_OP
		else
			#the string is not legal
			abort("Error. Invalid relation operator. Analysis terminated.")
		end
	when "!"
		add_char
		$next_token = $NEG_OP
	else
		add_char
		$next_token = $EOF
	end
end

def lex()
	$lexeme.clear
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
		#to do this, we join the lexeme together
		if $lexeme.join == "true" || $lexeme.join == "false"
			$next_token = $BOOL_LIT
		else
			$next_token = $IDENT
		end
	when $DIGIT
		add_char
		get_char
		while $char_class == $DIGIT
			add_char
			get_char
		end
		$next_token = $INT_LIT
	when $UNKNOWN
			lookup($next_char)
			get_char
	when $EOF
		$next_token = $EOF
		$lexeme = ["E","O","F"]
	end
	puts "Next token is: " + $next_token.to_s + ", next lexeme is " + $lexeme.join
end

def bool_expr()
	#parse <and_term> { | <and_term>}
	puts "enter <bool_expr>"
	and_term
	while $next_token == $OR_OP
		lex()
		and_term()
	end
	puts "exit <bool_expr>"
end

def and_term()
	#parses and_term ::= bool_factor {& bool_factor}
	puts "enter <and_term>"

	bool_factor
	while $next_token == $AND_OP
		lex
		bool_factor
	end
	puts "exit <and_term>"
end

def bool_factor()
	puts "enter <bool_factor>"
	if $next_token == $BOOL_LIT
		lex
	elsif $next_token == $NEG_OP
		lex
		bool_factor
	elsif $next_token == $LEFT_PAREN
		lex
		bool_expr
		if $next_token == $RIGHT_PAREN
			lex
		else
			error
		end
	else
		relation_expr
	end
	puts "exit <bool_factor>"
end


def relation_expr()
	puts "enter <relation_expr>"
	if $next_token == $IDENT
		lex
	else
		error
	end

	while $next_token == $REL_OP
		lex
		if $next_token == $IDENT
			lex
		else
			error
		end
	end
	puts "exit <relation_expr>"
end




######################Main function analogue##############################
#open input file in read mode
#by changing the name of the input file, I can change the input without having to rewrite it every time
$INPUT_FILE = File.open("input_2.txt", "r")
get_char()
while $next_token != $EOF
	lex
	if $next_token != $EOF
		bool_expr
	end
end
$INPUT_FILE.close
