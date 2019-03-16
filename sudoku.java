import java.util.*;

class sudoku {

    public static final int   side = 9;
    int[] grid;

    int[] getPossible(int pos) {

        int[] possible = {0,1,2,3,4,5,6,7,8,9};

        int row         = pos / side;
        int col         = pos % side;
        int grid_corner = (row / 3) * 27 + (col / 3) * 3;

        // Check 3x3 grid
        possible[ grid[grid_corner   ] ] = 0;
        possible[ grid[grid_corner+1 ] ] = 0;
        possible[ grid[grid_corner+2 ] ] = 0;
        possible[ grid[grid_corner+9 ] ] = 0;
        possible[ grid[grid_corner+10] ] = 0;
        possible[ grid[grid_corner+11] ] = 0;
        possible[ grid[grid_corner+18] ] = 0;
        possible[ grid[grid_corner+19] ] = 0;
        possible[ grid[grid_corner+20] ] = 0;
        
        // Check row
        for (int i = 0; i < side; i++)
            possible[ grid[row*side+i] ] = 0;

        // Check column
        for (int i = 0; i < side; i++)
            possible[ grid[i*side+col] ] = 0;

        return possible;
    }

    int countPossible(int pos) {
        int[] possible = getPossible(pos);
        int tally = 0;
        for (int i = 1; i <= side; i++)
            if (possible[i] != 0)
                tally++;
        return tally;
    }

    int getValue(int pos) {
        int[] possible = getPossible(pos);
        for (int i = 1; i <= side; i++)
            if (possible[i] != 0)
                return possible[i];
        return 0;
    }

    boolean solve() {
        int min         = 0;
        int min_pos     = 0;
        int deductions  = 0;
        int options     = 0;
        int zerocount   = 0;

        while (true) {
            min        = side+1;
            min_pos    = -1;
            deductions = 0;
            zerocount  = 0;
            for (int i = 0; i < side*side; i++) {
                if (grid[i] == 0) {
                    zerocount++;
                    options = countPossible(i);
                    if (options == 0)
                        return false;

                    if (options == 1) {
                        grid[i] = getValue(i);
                        deductions++;
                    }
                    else {
                        if (options <= min) {
                            min_pos = i;
                            min     = options;
                        }
                    }
                }
            }

            if (deductions == 0)
                break;
        }

        if (zerocount == 0)
            return true;

        int[] original_grid   = new int[side*side];
        int[] possible        = getPossible(min_pos);

        for (int i = 0; i < side*side; i++)
            original_grid[i] = grid[i];

        for (int i = 1; i <= side; i++) {
            if (possible[i] != 0) {
                grid[min_pos] = i;
                if (solve())
                    return true;
                else {
                    for (int j = 0; j < side*side; j++)
                        grid[j] = original_grid[j];
                }
            }
        }
        return false;
    }

    sudoku() {
        grid = new int[side * side];
        Scanner scan = new Scanner(System.in);

        for (int i = 0; i < side * side; i++)
            grid[i] = scan.nextInt();

        solve();

        for (int i = 0; i < side; i++) {
            for (int j = 0; j < side; j++)
                System.out.print(" "+grid[i*side+j]);
            System.out.println("");
        }
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();
        new sudoku();
        System.out.println("Execution time: "+(System.currentTimeMillis()-start)+" millisec.");
    }
}
