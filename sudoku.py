#!/usr/bin/env python

from fileinput import input

class Sudoku:

    def getPossible(self, pos):
        possible = {1:1,2:1,3:1,4:1,5:1,6:1,7:1,8:1,9:1}
        grid_corner = self.sector[pos]
        row = pos / self.side
        col = pos % self.side

        # Check 3x3 grid
        for x in [0,1,2,9,10,11,18,19,20]:
            if self.grid[grid_corner+x] in possible: possible.pop(self.grid[grid_corner+x])

        for i in range(self.side):
            if self.grid[row*self.side+i] in possible: possible.pop(self.grid[row*self.side+i])
            if self.grid[i*self.side+col] in possible: possible.pop(self.grid[i*self.side+col])

        return possible

    def solve(self):
        min        = 0
        min_pos    = 0
        options    = 0
        zerocount  = 0
        deductions = 0

        while True:
            min = self.side + 1
            min_pos = -1
            zerocount = 0
            deductions = 0
            for i in range(self.side * self.side):
                if self.grid[i] != 0:
                    continue
                zerocount += 1
                possible = self.getPossible(i)
                count = len(possible)
                if count == 0:
                    return False

                if count == 1:
                    self.grid[i] = possible.keys()[0]
                    deductions += 1
                else:
                    if count < min:
                        min_pos = i
                        min     = count

            if deductions == 0:
                break

        if zerocount == 0:
            return True

        original_grid = self.grid[:]
        possible      = self.getPossible(min_pos)

        for key in possible:
            self.grid[min_pos] = key
            if self.solve(): return True
            self.grid = original_grid[:]
        return False

    def __init__(self):
        self.sector = [  0, 0, 0, 3, 3, 3, 6, 6, 6,
                         0, 0, 0, 3, 3, 3, 6, 6, 6,
                         0, 0, 0, 3, 3, 3, 6, 6, 6,
                        27,27,27,30,30,30,33,33,33,
                        27,27,27,30,30,30,33,33,33,
                        27,27,27,30,30,30,33,33,33,
                        54,54,54,57,57,57,60,60,60,
                        54,54,54,57,57,57,60,60,60,
                        54,54,54,57,57,57,60,60,60 ]
        self.side = 9
        self.grid = [] 

        for line in input():
            self.grid += [int(i) for i in line.split()]

        self.solve()

        for (i, val) in enumerate(self.grid):
            print val,
            if i%self.side == self.side-1:
                print
 
if __name__ == '__main__':
    Sudoku()
