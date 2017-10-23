require 'open-uri'
require 'json'
require 'time'

class LongestWordController < ApplicationController

  def game
    @size = params[:number_of_letters].to_i
    @random_letters = generate_grid(10)
    @start_time = Time.now
  end

  def score
    @start = Time.parse(params[:start_time]).to_i
    @end = Time.now.to_i
    @word = params[:player_word].to_s.gsub!(/[^0-9A-Za-z]/, '')
    @grid = params[:grid]
    @score = run_game(@word, @grid, @start, @end)
  end

  private

  def generate_grid(grid_size)
    random = []
    grid_size.times do
      alphabet = ('a'..'z').to_a
      random << alphabet[rand(alphabet.length)]
    end
    random
  end

  def english_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    parsed_result = JSON.parse(open(url).read)
    last_letter = attempt.split('').last

    if parsed_result["found"] == true
      return true
    elsif last_letter == "s"
      singularized = attempt.chop
      new_url = "https://wagon-dictionary.herokuapp.com/#{singularized}"
      new_result = JSON.parse(open(new_url).read)
      return true if new_result["found"] == true
    else
      return false
    end
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

  def run_game(attempt, grid, start_time, end_time)
    time = end_time - start_time
    if english_word?(attempt) && in_grid?(attempt, grid)
      score = compute_score(time, attempt)
      if score == 0
        message = "#{attempt.capitalize} is a word, but you took way to long bro"
      else
        message = "Great job!"
      end
    elsif english_word?(attempt) && in_grid?(attempt, grid) == false
      score = 0
      message = "Cheater! You used a letter that was not in the grid"
    else
      score = 0
      message = "#{attempt.capitalize}? Did you make that up? That's not an english word!"
    end
    add_to_hash(score, time, message)
  end

  def compute_score(time, attempt)
    final_score = time > 60.0 ? 0 : attempt.split("").size * (1.0 - time / 60.0)
    return final_score.round
  end


  def add_to_hash(score, time, message)
    my_hash = {}
    my_hash[:score] = score
    my_hash[:time] = time
    my_hash[:message] = message
    return my_hash
  end

end
