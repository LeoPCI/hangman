require 'sinatra'
require 'sinatra/reloader' if development?

class Hangman
require 'date'
require 'yaml'

attr_reader :word
attr_reader :head
attr_reader :torso
attr_reader :lhand
attr_reader :rhand
attr_reader :larm
attr_reader :rarm
attr_reader :lleg
attr_reader :rleg
attr_reader :lfoot
attr_reader :rfoot


	def newgame
		@file = []
		@known = []
		@points = 0

		paragraphs = File.read("dictionary.txt").split(/\s*?\r\s*/).map do |paragraph|
			@file << paragraph
		end

		@word = ""
		until (@word.length>4 && @word.length<8)
		    num = rand(@file.size)
		    @word = @file[num].downcase
		end

		@word = @word.split("")
		for i in 0...@word.length do
		    @known << "_"
		end
	end

	def save
		status = [@word, @known, @points]
		filename = "saved.yaml"
		File.open(filename, "w") do |file|
			file.puts YAML::dump(status)
		end
	end

	def load
		data = YAML::load(File.open("saved.yaml"))
		@word = data[0]
		@known = data[1]
		@points = data[2]
	end

	def play(guess)

	  @head = 0
	  @larm = 0
	  @rarm = 0
	  @lhand = 0
	  @rhand = 0
	  @lleg = 0
	  @rleg = 0
	  @lfoot = 0
	  @rfoot = 0
	  @torso = 0

	  if @word.include? guess
		for i in 0...@word.length do
			@known[i] = @word[i] if @word[i] == guess
		end
	  else
		@points += 1
	  end

	  @points -= 1 if guess == nil

	  @head = 1 if @points > 0
	  @torso = 1 if @points > 1
	  @larm = 1 if @points > 2
	  @rarm = 1 if @points > 3
	  @lhand = 1 if @points > 4
	  @rhand = 1 if @points > 5
	  @lleg = 1 if @points > 6
	  @rleg = 1 if @points > 7
	  @lfoot = 1 if @points >8
	  @rfoot = 1 if @points > 9

	  return "YOU LOSE" if @points>9 
	  return "YOU WIN" if @known==@word
	  return @points

	end

	def show_known
		return @known.join(" ")
	end
end



game = Hangman.new
game.newgame

get '/' do
	points_etc = game.play(params["guess"])
	erb :index, :locals => {:points_etc => points_etc, :known => game.show_known, :word => game.word, :head => game.head, :larm => game.larm, :rarm => game.rarm, :lhand => game.lhand, :rhand => game.rhand, :rleg => game.rleg, :lleg => game.lleg, :lfoot => game.lfoot, :rfoot => game.rfoot, :torso => game.torso}
end

post '/new' do
	game = Hangman.new
    game.newgame
    redirect '/'
end

post '/save' do
    game.save
    redirect '/'
end

post '/load' do
    game.load
    redirect '/'
end