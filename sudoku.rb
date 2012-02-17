#!/usr/bin/ruby

# Sudoku
# By James Church
# 20051228

class Sudoku

    # This class computes the Sudoku number puzzle based on a partial puzzle passed to it.
    #
    # The Sudoku puzzle consist of a 9 by 9 grid of numbers, with each square containing a
    # number from 1 to 9. Only one occurance of a number is allowed in each row, column,
    # and 3 by 3 sector. When a partial puzzle is passed to it, the number 0 is considered
    # to be a blank square which needs to be evaluated.
    #
    # A typical completed Sudoku puzzle looks like this:

    #         1 2 3 | 4 5 6 | 7 8 9
    #         4 5 6 | 7 8 9 | 1 2 3
    #         7 8 9 | 1 2 3 | 4 5 6
    #        -----------------------
    #         2 1 4 | 3 6 5 | 8 9 7
    #         3 6 5 | 8 9 7 | 2 1 4
    #         8 9 7 | 2 1 4 | 3 6 5
    #        -----------------------
    #         5 3 1 | 6 4 2 | 9 7 8
    #         6 4 2 | 9 7 8 | 5 3 1
    #         9 7 8 | 5 3 1 | 6 4 2

    # initialize
    # If called with no arguments, then "grid" is set to an 81 element array containing all zeros.
    # If an array is passed to it, that array becomes grid.
    #
    #                array:int
    def initialize ( *args )

        if    args.length == 0
            @grid = Array.new( 81, 0 )

        elsif args.length == 1
            @grid = *args[0]

        end # if

        @repairStack  = []
        @sector       = [
                         0,0,0,1,1,1,2,2,2,
                         0,0,0,1,1,1,2,2,2,
                         0,0,0,1,1,1,2,2,2,
                         3,3,3,4,4,4,5,5,5,
                         3,3,3,4,4,4,5,5,5,
                         3,3,3,4,4,4,5,5,5,
                         6,6,6,7,7,7,8,8,8,
                         6,6,6,7,7,7,8,8,8,
                         6,6,6,7,7,7,8,8,8
                        ]

    end # initialize

    def corner
        return (@grid[0]*100) + (@grid[1]*10) + (@grid[2]*1)
    end # corner

    # solve
    # A depth-first-search(DFS) algorithm to solving the puzzle currently stored in grid
    # Returns true if the puzzle was solved, and false if not. The solution is stored
    # in "grid".
    #
    # Some notes:
    #         This DFS approach has a worst-case branching factor of 9 and an average
    #     branching factor of 4.
    def solve
        zeroOpts = deduce

        zeroLocal = zeroOpts.pop()

        return true if ( zeroLocal == -1 )

        for @grid[zeroLocal] in zeroOpts
            return true if solve
        end # for

        @grid[zeroLocal] = 0

        repairs = @repairStack.pop()
        repairs.times do
            @grid[ @repairStack.pop() ] = 0
        end # For

        false
    end # solve

    # printGrid - prints the current grid on the screen.
    def printGrid
        for i in 0..8
            puts @grid[i*9+0].to_s + " " +
                 @grid[i*9+1].to_s + " " +
                 @grid[i*9+2].to_s + " " +
                 @grid[i*9+3].to_s + " " +
                 @grid[i*9+4].to_s + " " +
                 @grid[i*9+5].to_s + " " +
                 @grid[i*9+6].to_s + " " +
                 @grid[i*9+7].to_s + " " +
                 @grid[i*9+8].to_s

        end # for
    end # printGrid

    # inRow - Determines if a value is already on a row
    # Inputs:
    #    value: Any value from 1 to 9
    #    row:   Any row from 0 to 8
    # Outputs:
    #    A boolean true if the value is already on the row, false if not.
    #
    #          int    int
    def inRow (value, row)
        bool = false

        for i in 0..8
             if @grid[ row*9+i ] == value then
                 bool = true
                 break
             end # if
        end # for

        bool # return
    end # inRow

    # inColumn - Determines if a value is already on a column
    # Inputs:
    #    value: Any value from 1 to 9
    #    col:   Any column from 0 to 8
    # Outputs:
    #    A boolean true if the value is already on the column, false if not.
    #
    #             int    int
    def inColumn (value, column)
        bool = false

        for i in 0..8
             if @grid[ i*9+column ] == value
                 bool = true
                 break
             end # if
        end # for

        bool # return
    end # inColumn

    # inSector - Determines if a value is already in a sector
    # Inputs:
    #    value:  Any value from 1 to 9
    #    sector: Any sector from 0 to 8
    # Outputs:
    #    A boolean true if the value is already in that sector, false if not.
    #
    #             int    int
    def inSector (value, sector)

        case sector
            when 0: i = 0
            when 1: i = 3
            when 2: i = 6
            when 3: i = 27
            when 4: i = 30
            when 5: i = 33
            when 6: i = 54
            when 7: i = 57
            when 8: i = 60
        end # case

        [ @grid[i   ], @grid[i+1 ], @grid[i+2],
          @grid[i+9 ], @grid[i+10], @grid[i+11],
          @grid[i+18], @grid[i+19], @grid[i+20]
        ].include?(value)
    end # inSector

    # deduce
    # This method systematically evaluates each blank square (i.e. the ones with a zero) and determines all
    # of the possible values for that blank. If a square evaluates down to only one possibility, then that is
    # written to the grid. This function loops until it can't make any more evaluations, then it quits.
    def deduce

        zeroOpts   = []
        pushGrid   = []
        optsLocal  = -1
        fewestOpts = 10
        repairs    = @repairStack.length

        @grid.each_index do |i|
            if @grid[i] == 0
                pushGrid.push( (1..9).to_a )
            else
                pushGrid.push( 0 )
            end # if
        end # each_index

        while true
            deductions = 0

            @grid.each_index do |i|
                next if @grid[i] != 0

                row = i / 9
                col = i % 9
                sec = @sector[i]

                pushGrid[i].each_index do |val|
                    if inRow(pushGrid[i][val], row) or inColumn(pushGrid[i][val], col) or inSector(pushGrid[i][val], sec)
                        deductions = deductions + 1
                        pushGrid[i][val] = 0
                    end # if
                end # each_index

                pushGrid[i].delete(0)

                if  pushGrid[i].length == 1
                    @grid[i] = pushGrid[i][0]
                    @repairStack.push(i)
                end
            end # each_index

            break if deductions == 0
        end # while

        @repairStack.push( @repairStack.length - repairs )

        @grid.each_index do |i|
            if @grid[i] == 0 and pushGrid[i].length < fewestOpts
                fewestOpts = pushGrid[i].length
                optsLocal  = i
            end # If
        end # Each_index

        zeroOpts = pushGrid[optsLocal][0..-1] if optsLocal != -1
        zeroOpts.push(optsLocal)
    end # deduce
end # class Suduko

##################
#   Start Here   #
##################

# This first bit of code reads in 9 lines, each containing nine numbers from standard input,
# and then formats those 81 numbers into a single dimensional 81 element array of integers.

s = 0
re = /(\d)\s*(\d)\s*(\d)\s*(\d)\s*(\d)\s*(\d)\s*(\d)\s*(\d)\s*(\d)/

myGrid = []
9.times do
    line  = gets.chomp
    match = re.match(line)
    for i in 1..9
        myGrid.push( match[i].to_i )
    end # for
end # 9 times

mySudoku = Sudoku.new(myGrid)
mySudoku.solve
mySudoku.printGrid

