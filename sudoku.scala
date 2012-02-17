import scala.Math

class Sudoku(grid: Array[Int]) {
    val side = Math.sqrt(grid.length)
    val sectorSize = Math.sqrt(side)
    val offsets      = (0 until side).toList.map{ pos => ((pos / sectorSize) * side * sectorSize) + ((pos % sectorSize) * sectorSize) }
    val inneroffsets = (0 until side).toList.map{ pos => (pos / sectorSize) * side + (pos % sectorSize) }

    def getRow(pos: Int): Int = pos / side
    def getCol(pos: Int): Int = pos % side
    def getSec(pos: Int): Int = (pos / (side * sectorSize)) * sectorSize + ((pos % side) / sectorSize)

    def getPossible(pos: Int): List[Int] = {
        val row = getRow(pos)
        val col = getCol(pos)
        val sec = getSec(pos)
        val secOffset = offsets(sec)

        val rowValues = for (i <- List.range(0, side) if grid(row*side+i)                  != 0) yield grid(row*side+i)
        val colValues = for (i <- List.range(0, side) if grid(i*side+col)                  != 0) yield grid(i*side+col)
        val secValues = for (i <- List.range(0, side) if grid(secOffset + inneroffsets(i)) != 0) yield grid(secOffset + inneroffsets(i))

        return for (i <- List.range(1, side+1) if
                         rowValues.exists(i==) == false &&
                         colValues.exists(i==) == false &&
                         secValues.exists(i==) == false ) yield i
    }

    def printSolution(): Unit = {
        (0 until side).foreach { i =>
            (0 until side).foreach { j =>
                print(grid(i*side+j) + " ")
            }
            println("")
        }
        println("")
    }

    def solve(): Boolean = {
        var min        = 0
        var min_pos    = 0
        var options    = 0
        var zerocount  = 0
        var deductions = 0
        val tempgrid = new Array[Int](grid.length)

        do {
            min        = side+1
            min_pos    = -1
            zerocount  = 0
            deductions = 0

            (0 until (side*side)).foreach { i =>
                if (grid(i) == 0) {
                    val possible = getPossible(i)
                    zerocount += 1

                    if (possible.length == 0) {
                        return false
                    }

                    if (possible.length == 1) {
                        deductions += 1
                        grid(i) = possible(0)
                    }
                    else {
                        if (possible.length < min) {
                            min_pos = i
                            min = possible(0)
                        }
                    }
                }
            }
        } while (deductions > 0)

        if (zerocount == 0) {
            return true
        }

        val possible = getPossible(min_pos)
        (0 until grid.length).foreach { i => tempgrid(i) = grid(i) }

        possible.foreach { index =>
            grid(min_pos) = index
            if (solve()==true) {
                return true
            }

            (0 until grid.length).foreach { i => grid(i) = tempgrid(i) }
        }
        return false
    }
}

object SudokuApp {
    def collectGrid(): List[Int] = {
        val line = readLine()
        if (line == null)
            return Nil

        return ( for (x <- line.split(" ")) yield Integer.parseInt(x) ).toList ::: collectGrid()
    }

    def main(args:Array[String]) = {
        val grid = collectGrid()
        val thispuzzle = new Sudoku(grid.toArray)
        thispuzzle.solve()
        thispuzzle.printSolution()
    }
}
