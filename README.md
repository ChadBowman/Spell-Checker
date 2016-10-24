# Spell-checker for Centricient
### By: Chad Alexander Bowman (chad.bowman0@gmail.com)

This Ruby script functions as a basic spell-checker. When a word isn't found in the "word.txt" dictionary, it first looks for fast suggestions. Words that match with a character added, removed, or flipped. If none of those options work, it resorts to a relational approach and returns to return the best suggestion. The first letter of test words are ignored as most misspelled words have at least the first letter correct, doing this also improves performance.

### Running the script
**Important**: Use [JRuby](http://jruby.org) (Ruby on the JVM) for a huge increase in performance due to true threading.
```
ruby spellchecker.rb file_to_test
```
or better:
```
jruby spellchecker.rb file_to_test
```