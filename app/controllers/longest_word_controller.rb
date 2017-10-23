require 'open-uri'
require 'json'
require 'time'

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
    @start = Time.parse(params[:start_time]).to_i
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
      if score == 0
        message = "You took way to long bro"
      else
        message = "well done"
      end
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
    final_score = time > 60.0 ? 0 : attempt.split("").size * (1.0 - time / 60.0)
    return final_score.round
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