#!/usr/bin/ruby
require_relative './colorize.rb'

$polarise=-1
$polflip=140
$TRAILS=true
$SLEEP=0.05

module Screen
	attr_accessor :minrows, :mincols, :maxrows, :maxcols
	def initialize ## ( row0=nil, col0=nil, rowx=nil, colx=nil )
		@minrows||= 1
		@maxrows||= `tput lines`.chomp.to_i
		@mincols||= 1
		@maxcols||= `tput cols`.chomp.to_i
		@old_state=nil
		cursor_to 1,1
	end
#	def dump
#		print "(#{@minrows},#{@mincols})..(#{@maxrows},#{@maxcols})\t".cyan
#		puts "(#{@@minrows},#{@@mincols})..(#{@@maxrows},#{@@maxcols})".brown
#	end
	def cursor_reset
		print "\033[H"
	end
	def clear_screen
		print "\033[2J"
	end
	def cursor_to ( row=1, col=1)
		row=@minrows if row < @minrows
		row=@maxrows if row > @maxrows
		col=@mincols if col < @mincols
		col=@maxcols if col > @maxcols
#		col-=1 if row==@maxrows && col==@maxcols # messy to avoid screen scroll
		print "\033[#{row};#{col}H"
	end
	def self.maxrows
		@maxrows
	end
	def self.maxcols
		@maxcols
	end
	def hide_cursor
    	# save previous state of stty
		@old_state = `stty -g` if @old_state.nil?
		# disable echoing and enable raw (not having to press enter)
		system "stty raw -echo"
	end
	def show_cursor
	    # restore previous state of stty
        system "stty #{@old_state} > /dev/null"
        @old_state = nil
    end
end

class Bug 
	attr_accessor :row, :col, :char, :color, :health
	include Screen
	def initialize(color, health: 9, char: '*')
		@color=color
		@char='O'
		@health||=10
		super()
		randomStart
	end
	def randomStart
		@row=rand(@maxrows -1)+1
		@col=rand(@maxcols -1)+1
#		put_bug
	end	
	def where?
		[@row,@col]
	end
	def move_bug
		unput_bug
		wr=@row<=>@maxrows/2
		wc=@col<=>@maxcols/2
#		@row+=(rand(5)<=>2+wr) 
#		@row+=(rand(7)<=>3+wr) 
#		@col+=(rand(5)<=>2+wc)
#		@col+=(rand(7)<=>3+wc)
#		@row+=(rand(7)<=>3+wr*$polarise) 
#		@col+=(rand(5)<=>2+wc*$polarise)
		dr=(rand(7)<=>3+wr*$polarise)
		dc=(rand(5)<=>2+wc*$polarise)
		@row+=dr
		@col+=dc
		put_bug
	end
	def boundaries
		@row=1 if @row<@minrows
		@col=1 if @col<@mincols
		@row=@maxrows if @row>@maxrows
		@col=@maxcols if @col>@maxcols
	end
	def put_bug
		cursor_to( @row,@col )
		print "#{char.upcase}".send(color).bold
		cursor_to( 1,1 )
	end
	def unput_bug
		cursor_to( @row,@col )
		if ( defined? $TRAILS and $TRAILS) ##==true )
			print "#{char.downcase}".send(color)	## visible trails
		else
			print ' '
		end
		cursor_to( 1,1 )
#		print "(#{@row},#{col})  ".cyan
	end
	def dump
		[ self.color, self.row, self.col ]
	end
end
include Screen
##hide_cursor
clear_screen
bugs=[]
bugs << Bug.new('red', health: 7, char: '*')
bugs << Bug.new('green')
bugs << Bug.new('magenta')
bugs << Bug.new('cyan')
bugs << Bug.new('brown')
bugs << Bug.new('gray')
##bugs << Bug.new('blue')
=begin
bugs << Bug.new('red', health: 7, char: '*')
bugs << Bug.new('green')
bugs << Bug.new('magenta')
bugs << Bug.new('cyan')
bugs << Bug.new('brown')
bugs << Bug.new('gray')
##bugs << Bug.new('blue')
=end

$Enjoy = 6
while true

	test=200
	##print "#{test} ".cyan
	##c=STDIN.getc.chr
	clear_screen

	test.times do |i|
		$polarise*=-1 if i%$polflip==0
		i=test-i
		bugs.each do |bug|
			bug.move_bug
#			bug.put_bug
		end
##		print "#{i.to_s.ljust(4)}".cyan
##		sleep $SLEEP ## 0.01
#	rescue Interrupt => e
#		break
#	end
	end
	
	sleep $Enjoy
	bugs.each do |bug|
		bug.randomStart
	end
	
end

c= STDIN.getc.chr


END { show_cursor }


__END__

