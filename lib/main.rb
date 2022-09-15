require 'yaml'
require "colorize"

class Game
  attr_accessor :word, :guess, :word_array, :lives, :wrong_words

  def initialize()
    @word = get_word
    @word_array = @word.split("")
    @guess = Array.new(@word.length, "_")
    @lives = 8
    @wrong_words = []

    print "[1] to start a new game\n"\
          "[2] to load an old game\n"
    print "Insert your choice: ".yellow
    old_game = gets.chomp
    if old_game == "2"
      puts "LOADING GAME...".yellow
      load_game
    elsif old_game == "1"
      puts "STARTING NEW GAME".green
    else
      puts "WRONG CHOICE"
      initialize
    end
    start_turn
  end

  def get_word
    word = ''
    while word.length <= 4 || word.length >= 13
      word = File.readlines('words.txt').sample.chomp
    end
    word
  end

  def check_guess
    puts "LIVES REMAINING: #{@lives}"
    if @wrong_words.length > 0
      puts "WRONG GUESSES: #{@wrong_words.join(", ")}"
    end
    puts @guess.join(" ")
    print "Insert your guess: "
    player_guess = gets.chomp.downcase
    if player_guess.length > 1 || player_guess =~ /\d/
      puts "INVALID GUESS!".red
    elsif @word_array.include?(player_guess)
      puts "CORRECT GUESS!".green
      @word_array.each_with_index do |letter, index|
        if player_guess == letter
          @guess[index] = letter
        end
      end
    else
      puts "WRONG GUESS!".red
      @wrong_words << player_guess
      @lives -= 1
    end
  end

  def start_turn
    while @lives > 0 && @guess.include?("_") == true
      save = save_game?
      if save == true
        open_save
        puts "GAME HAS BEEN SAVED!".green
        break
      elsif
        check_guess
      end
    end
    if @lives < 1
      puts "YOU LOSE! GAME OVER!"
    elsif @guess.include?("_") == false
      puts "YOU WON! GAME OVER!"
    end
  end

  def open_save
    File.open('saves/save.yaml', 'w') do |file|
      file.puts(save_game)
    end
  end

  def save_game? 
    puts
    print "[1] to continue game"\
    "\n[2] to save game"
    print "\n Insert your choice: ".yellow
    choice = gets.chomp
    if choice == "1"
      return false
    elsif choice == "2"
      return true
    else
      puts "WRONG OPTION!".red
      save_game?
    end
  end

  def save_game
    YAML.dump ({
      :word => @word,
      :word_array => @word_array,
      :guess => @guess,
      :lives => @lives,
      :wrong_words => @wrong_words
    })
  end

  def load_game
    file_check = File.exist?("saves/save.yaml")
    if file_check
      file = File.read("saves/save.yaml")
      save = YAML.load(file)

      self.word = save[:word]
      self.word_array = save[:word_array]
      self.guess = save[:guess]
      self.lives = save[:lives]
      self.wrong_words = save[:wrong_words]
    else
      puts "SAVE NOT FOUND, STARTING NEW GAME...".yellow
    end
  end
end

game = Game.new()