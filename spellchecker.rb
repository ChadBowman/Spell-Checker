# This script functions as a spell-checker compared to a given dictionary "words.txt".
# The dictionary file needs to be in the same file as this script.
#
# *IMPORTANT* Run with JRuby (jruby.org) for a huge increase in performance due to real hardware
# threading. 
#
# Author::    Chad Alexander Bowman (mailto:chad.bowman0@gmail.com)
# Copyright:: Copyright (c) 2016
# License::   Distributes under the same terms as Ruby

# Global variables 
@dictionary = Hash.new 			# Hash of words contained in dictionary
@words_to_check = Array.new 	# Array of words to be checked
@start = Time.now 				# Starting time to show elapsed time

# Check for argument input
if ARGV.empty?
	puts "Please input a newline delimited file to test against."
	exit
end

# Pre-processing of double-Hash to contain dictionary words
# Words are separated by their first letter as misspellings don't typically include a wrong 
# 	first letter.
alph = "0abcdefghijklmnopqrstuvwxyz"

# Create a Hash for each letter as well as one for everything else
# 	(words that don't begin with a letter)
alph.length.times do |i|
	@dictionary[alph[i]] = Hash.new
end

# Add dictionary words to Hash
begin
	File.new("words.txt", "r").each_line do |line|  
		
		line = line.downcase.chomp	# standardize words, remove newlines

		# Words that don't start with a letter go into the '0' Hash
		if @dictionary[line[0]].nil?
			@dictionary['0'][line] = true
		
		# Else words go into their respective Hashes
		else
			@dictionary[line[0]][line] = true
		end	
	end

rescue Exception => e
	puts "Dictionary file 'words.txt' not found!"
	exit
end

# Add and pre-process words to check into an array
begin
	ARGV.each do |word|
		if word =~ /\w+\.\w+/
			File.new(word, "r").each_line do |line|

				line = line.downcase.chomp # Standardize word
				@words_to_check << line
			end
		else
			@words_to_check << word
		end
	end

rescue Exception => e
	puts "Words to check file not found!"
	exit
end


# Checks to see if by removing one letter from the test word produces a match.
#
# ==== Parameters
#
# * +dict_word+ - Correct word found in dictionary.
# * +word+ - Word to be compared against.
#
# ==== Returns
#
# * true - When removing a letter from the test word matches the dictionary word.
# * false - When no match is found.
#
# ==== Examples
#
# 	extra_letter("door", "dooor") => true
# 	extra_letter("door", "doort") => true
# 	extra_letter("door", "dooort") => false
# 	extra_letter("door", "door") => false
def extra_letter( dict_word, word )

	num = word.length - 1

	# Remove a letter from the test word to see if a match results
	num.times do |i|

		test_word = word[0, i+1] + word[i+2, num]

		# Match made
		return true if @dictionary[test_word]	
	end

	# No match found
	return false
end

# Checks to see if by flipping adjacent letters in test word produces a match.
#
# ==== Parameters
#
# * +dict_word+ - (String) Correct word found in dictionary.
# * +word+ - (String) Word to be compared against.
#
# ==== Returns
#
# * true - When flipping adjacent letters in the test word matches the dictionary word.
# * false - When no match is found.
#
# ==== Examples
#
# 	flipped_letter("desk", "dsek") => true
# 	flipped_letter("desk", "desk") => false
# 	flipped_letter("desk", "block") => false
def flipped_letter( dict_word, word )

	# Flip adjacent letters in test word to see if a match results
	word.length.times do |i|

		if i < word.length - 2
			test_word = word[0, i+1] + word[i+2] + word[i+1] + word[i+3, word.length-1]
		end
		
		# Match found
		return true if dict_word.eql? test_word
	end

	# No match found
	return false
end

# Checks to see if by adding a letter from the dictionary word to the word produces a match.
#
# ==== Parameters
#
# * +dict_word+ - (String) Correct word found in dictionary.
# * +word+ - (String) Word to be compared against.
#
# ==== Returns
#
# * true - When adding a letter to the test word matches the dictionary word.
# * false - When no match is found.
#
# ==== Throws
#
# * ArgumentError - When the length of the dictionary word is less than the test word.
#
# ==== Examples
#
# 	missing_letter("desk", "dsk") => true
# 	missing_letter("desk", "desk") => false
# 	missing_letter("desk", "de") => false
# 	missing_letter("desk", "block") => throws ArgumentError
def missing_letter( dict_word, word )

	# If dictionary word is less than test word, throw error
	if dict_word.length < word.length
		throw ArgumentError, "Dictionary word is smaller than word to compare!"
	end

	# Add a letter from the dictionary word to see if a match results
	dict_word.length.times do |i|

		if i < word.length
			test_word = word[0, i+1] + dict_word[i+1] + word[i+1, word.length-1]
			
			# Match found
			return true if dict_word.eql? test_word
		end
	end
	
	# No match found
	return false
end

# Compares two words and adds the 'defects' between them. This method returns a score reflecting
# how similar the two words are to each other. The higher the number the least similar the words
# are.
#
# ==== Parameters
#
# * +dict_word+ - (String) Word from dictionary.
# * +word+ - (String) Word to be compared against.
#
# ==== Returns
#
# * +Fixnum+ - Score >= 0. The higher the number the less similar the word.
#
# ==== Examples
#
# 	defect_count("desk", "desk") => 0
# 	defect_count("desk", "disk") => 2
def defect_count( dict_word, word )

	dict_letters = Hash.new 	# Characters in dictionary word
	word_letters = Hash.new 	# Characters in test word

	# Add the characters to hash, add the values if character is already present.
	dict_word.length.times do |i|
		if dict_letters[dict_word[i]].nil?
			dict_letters[dict_word[i]] = 1
		else
			dict_letters[dict_word[i]] += 1
		end
	end

	# Do the same thing for the other word
	word.length.times do |i|
		if word_letters[word[i]].nil?
			word_letters[word[i]] = 1
		else
			word_letters[word[i]] += 1
		end
	end

	defects = 0 # Defect count to return
	
	# Compare the two words unique characters, for each non-matching character, add number of 
	# characters present as defects
	if dict_letters.size > word_letters.size
		dict_letters.each do |key, val|
			defects += val if word_letters[key].nil?		
		end
	else
		word_letters.each do |key, val|
			defects += val if dict_letters[key].nil?		
		end
	end

	# For the matching unique characters, add the difference in quantity as defects
	dict_letters.each do |kd, vd|
		word_letters.each do |kw, vw|

			defects += (vd - vw).abs if kd.eql? kw
		end
	end

	# Get the smallest word length
	bound = (dict_word.length < word.length)? dict_word.length : word.length

	# To reward words which have very similar sequences of characters, we add defects for
	# each character that does not match sequentially with other word.
	bound.times do |i|

		# add defect for each unmatching character
		defects += 1 unless dict_word[i].eql? word[i]
	end

	# return score
	return defects
end


# Spell-checks all words to test. Outputs to console CORRECT when a direct match is
# found, INCORRECT is no suggestion is available, or will suggest a single correct word.
def run

	threads = Array.new 	# a place to store threads

	# Use 4 threads when the word list is larger than 10
	number_of_threads = (@words_to_check.size < 10)? 1 : 4
	
	# Size of partisans 
	part = @words_to_check.size / number_of_threads

	# For each thread
	number_of_threads.times do |i|

		# Create a new Thread, add it to array
		threads << Thread.new {
			
			# To make sure the partitioning is complete, calculate the upper bound
			if i == number_of_threads - 1
				last = @words_to_check.size
			else
				last = ((i+1) * part) - 1
			end

			# For each word in partitioned section of words to check
			@words_to_check[(i * part)..last].each do |word|

				# Retrieve the correct Hash for the corresponding word
				section = (@dictionary[word[0]].nil?)? @dictionary['0'] : @dictionary[word[0]]

				# If direct match is found, return correct
				if section[word]
					puts "CORRECT [#{word}]"
				
				# Word is not a match
				else
					suggestion = nil 	# initialize a suggestion

					# First try to find the fast solutions
					# For each word in the section, test for flipped, extra, and missing letters
					section.each_key do |key|

						if flipped_letter(key, word)
							suggestion = key

						elsif extra_letter(key, word)
							suggestion = key

						elsif key.length > word.length # required comparison to avoid error
							suggestion = key if missing_letter(key, word)
						
						end
					end

					# Still no suggestion found, resort to a more expensive route
					if suggestion.nil?
						
						# suggestion value works as a tolerance for an INCORRECT output
						suggestion_value = 7

						# For each word in section
						section.each_key do |key|

							# Get the defect count
							count = defect_count(key, word)
							
							# if the defect count is better, add a suggestion and associated cost
							if count < suggestion_value

								suggestion_value = count
								suggestion = key
							end
						end
					end

					# No suggestion can be made
					if suggestion.nil?
						puts "INCORRECT [#{word}]"
					
					# Else, output the suggestion
					else
						puts "#{suggestion} suggested for [#{word}]"
						
					end
				end
			end
		}
	end

	# Run the Thread(s)
	threads.each {|t| t.join}	
end

run # Do work!
puts "-----\nCompleted #{@words_to_check.size} words in #{Time.now - @start} seconds!"