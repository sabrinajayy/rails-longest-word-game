require 'open-uri'
require 'json'

class LongestWordController < ApplicationController
  # def initialize
  #   @start = Time.now
  # end

  def game
    @size = params[:number_of_letters].to_i
    @random_letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @start = params[:start_time]
    @end = Time.now.to_i
    @word = params[:player_word].to_s
    @grid = params[:grid]
    @score = run_game(@word, @grid, @start, @end)
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    random = []
    grid_size.times do
      alphabet = ('a'..'z').to_a
      random << alphabet[rand(alphabet.length)]
    end
    random
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    parsed_result = JSON.parse(open(url).read)
    time = end_time - start_time
    if parsed_result["found"] == true && in_grid?(attempt, grid)
      score = compute_score(time, attempt)
      message = "well done"
    elsif parsed_result["found"] == true && in_grid?(attempt, grid) == false
      score = 0
      message = "you used a letter that was not in the grid"
    else
      score = 0
      message = "this is not an english word"
    end
    add_to_hash(score, time, message)
  end

  def compute_score(time, attempt)
    time > 60.0 ? 0 : attempt.split("").size * (1.0 - time / 60.0)
  end

  def in_grid?(word, grid)
    grid = grid.downcase.chars
    word.chars.each do |letter|
      if !grid.include? letter
        return false
      else
        grid.delete_at(grid.find_index(letter))
      end
    end
    return true
  end

  def add_to_hash(score, time, message)
    my_hash = {}
    my_hash[:score] = score
    my_hash[:time] = time
    my_hash[:message] = message
    return my_hash
  end

end
