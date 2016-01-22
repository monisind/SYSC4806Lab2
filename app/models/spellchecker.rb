require 'set'

class Spellchecker

  
  ALPHABET = 'abcdefghijklmnopqrstuvwxyz'

  #constructor.
  #text_file_name is the path to a local file with text to train the model (find actual words and their #frequency)
  #verbose is a flag to show traces of what's going on (useful for large files)

  def initialize(text_file_name)
    text = ""
    #read file text_file_name
    File.open(text_file_name, "r") do |f|
      f.each_line do |line|
	text << line.chomp << " "
      end
    end

    #extract words from string (file contents) using method 'words' below.
    word_list = words(text)

    #put in dictionary with their frequency (calling train! method)
    train!(word_list)
  end


  def dictionary
    #getter for instance attribute
    @dictionary  
  end

  
  #returns an array of words in the text.
  def words (text)
    return text.downcase.scan(/[a-z]+/) #find all matches of this simple regular expression
  end

  #train model (create dictionary)
  def train!(word_list)
    #create @dictionary, an attribute of type Hash mapping words to their count in the text {word => count}.
    #Default count should be 0 (argument of Hash constructor).

    @dictionary = Hash.new(0)
    word_list.each do |w|
        @dictionary[w] += 1
    end    
  end

  #lookup frequency of a word, a simple lookup in the @dictionary Hash
  def lookup(word)
    return @dictionary[word]
  end
  
  #generate all correction candidates at an edit distance of 1 from the input word.
  def edits1(word)  
    deletes    = [] 
    #all strings obtained by deleting a letter (each letter)    
    for i in 0..word.length-1
	temp = word.dup
	temp.slice!(i)
	deletes.push(temp)
    end    

    transposes = []
    #all strings obtained by switching two consecutive letters
    loop_count = word.length-2
    if loop_count > 0
      for i in 0..loop_count
	temp = word.dup
   	temp[i+1] = word[i]	
	temp[i] = word[i+1]
	transposes.push(temp)
      end
    end   

    inserts = []
    # all strings obtained by inserting letters (all possible letters in all possible positions)
    for i in 0..word.length
      ALPHABET.each_char do |c|
        temp = word.dup
        temp = temp.insert(i,c)
        inserts.push(temp)
      end
    end

    replaces = []
    #all strings obtained by replacing letters (all possible letters in all possible positions)
    for i in 0..word.length-1
      ALPHABET.each_char do |c|
        temp = word.dup
        temp[i] = c
        replaces.push(temp)
      end
    end

    return (deletes + transposes + replaces + inserts).to_set.to_a #eliminate duplicates, then convert back to array
  end
  

  # find known (in dictionary) distance-2 edits of target word.
  def known_edits2 (word)
    # get every possible distance - 2 edit of the input word. Return those that are in the dictionary.
    words1 = edits1(word)
    words2 = []
    words1.each do |w|
       words2.concat(edits1(w))
    end
    return known(words2.uniq)
  end

  #return subset of the input words (argument is an array) that are known by this dictionary
  def known(words)
  #find all words for which condition is true,you need to figure out this condition
    known_words = words.find_all {|w| @dictionary.has_key?(w)} 
    return known_words
  end


  # if word is known, then
  # returns [word], 
  # else if there are valid distance-1 replacements, 
  # returns distance-1 replacements sorted by descending frequency in the model
  # else if there are valid distance-2 replacements,
  # returns distance-2 replacements sorted by descending frequency in the model
  # else returns nil
  def correct(word)
    if @dictionary.has_key?(word)
      return [word]
    end
    
    dist1_replacements = known(edits1(word))
    if dist1_replacements.length != 0
 	return dist1_replacements.sort_by{|value| @dictionary[value]}.reverse
    end
     
    dist2_replacements = known_edits2(word)
    if dist2_replacements.length != 0
 	return dist2_replacements.sort_by{|value| @dictionary[value]}.reverse
    end
 return nil
  end
    
end

