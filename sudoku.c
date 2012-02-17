#include <stdio.h>

// This algorithm is now dated and flawed.
// The multi_sudoku.c program, while similar, is
// much better.

#define rows 9
#define cols 9

int solve ( void );

int myGrid[81];
int repairStack[300];
int stackPtr;
int guesses;
int sector[81] = {
                    0,0,0,1,1,1,2,2,2,
                    0,0,0,1,1,1,2,2,2,
                    0,0,0,1,1,1,2,2,2,
                    3,3,3,4,4,4,5,5,5,
                    3,3,3,4,4,4,5,5,5,
                    3,3,3,4,4,4,5,5,5,
                    6,6,6,7,7,7,8,8,8,
                    6,6,6,7,7,7,8,8,8,
                    6,6,6,7,7,7,8,8,8
                 };

void printGrid  (                       );
int  inRow      ( int value, int row    );
int  inColumn   ( int value, int column );
int  inSector   ( int value, int sector );
void deduce     ( int *zeroOptions      );
int  solve      ( void                  );

int main (void) {

    int i;

    guesses  = 0;
    stackPtr = -1;

    for ( i = 0; i < 81; i++ )
        scanf ("%d", &myGrid[i]);

    printf ("\n Before:\n");
    printGrid();
    solve();

    printf ("\n After:\n");
    printGrid();

    return 0;
} // End Main

void printGrid () {

    int i, j;

    for ( i = 0; i < 9; i++ ) {
        for ( j = 0; j < 9; j++ )
            printf ( "%d ", myGrid[ i*9+j ] );

        printf ("\n");
    } // End For

    return;
} // End printGrid

int inRow ( int value, int row ) {
    int i;

    for ( i = 0; i < 9; i++ )
        if ( myGrid[ row*9+i ] == value )
            return 1;

    return 0;
} // End inRow

int inColumn ( int value, int column ) {
    int i;

    for ( i = 0; i < 9; i++ )
        if ( myGrid[ i*9+column ] == value )
            return 1;

    return 0;
} // End inRow

int inSector ( int value, int sector ) {
    int j;

    switch ( sector ) {
        case 0: j = 0;  break;
        case 1: j = 3;  break;
        case 2: j = 6;  break;
        case 3: j = 27; break;
        case 4: j = 30; break;
        case 5: j = 33; break;
        case 6: j = 54; break;
        case 7: j = 57; break;
        case 8: j = 60; break;
    } // End Switch

    if ( myGrid[j   ] == value ) return 1;
    if ( myGrid[j+1 ] == value ) return 1;
    if ( myGrid[j+2 ] == value ) return 1;
    if ( myGrid[j+9 ] == value ) return 1;
    if ( myGrid[j+10] == value ) return 1;
    if ( myGrid[j+11] == value ) return 1;
    if ( myGrid[j+18] == value ) return 1;
    if ( myGrid[j+19] == value ) return 1;
    if ( myGrid[j+20] == value ) return 1;

    return 0;
}

void deduce ( int *zeroOptions ) {

    int optsLocal  = -1;
    int fewestOpts = 10;
    int repairs    = stackPtr;
    int pushGrid[81][10];
    int deductions;
    int i, j, row, col, sec;
    int onesCount, onesPlace;

    zeroOptions[0] = -1;

    for ( i = 0; i < 81; i++) {
        pushGrid[i][0] = i;
        for ( j = 1; j < 10; j++ )
            pushGrid[i][j] = 1;
    } // End For

    while (1) {
        deductions = 0;

        for ( i = 0; i < 81; i++ ) {
            if ( myGrid[i] != 0 ) continue;

            row = i / rows;
            col = i % rows;
            sec = sector[i];

            onesPlace = 0;
            onesCount = 0;

            for ( j = 1; j < 10; j++ ) {
                if ( pushGrid[i][j] == 0 ) continue;

                if ( inRow ( j, row ) || inColumn ( j, col ) || inSector ( j, sec ) ) {
                    deductions++;
                    pushGrid[i][j] = 0;
                } // End If
                else {
                    onesCount++;
                    onesPlace      = j;
                } // End If
            } // End For

            if ( onesCount == 1 ) {
                myGrid[i] = onesPlace;
                repairStack[++stackPtr] = i;
            } // End If

        } // End For

        if ( deductions == 0 ) break;
    } // End While

    repairStack[ stackPtr+1 ] = stackPtr - repairs;
    stackPtr++;

    for ( i = 0; i < 81; i++ ) {
        if ( myGrid[i] == 0 ) {
            onesCount = 0;

            for ( j = 1; j < 10; j++ )
                if ( pushGrid[i][j] == 1 )
                    onesCount++;

            if ( onesCount < fewestOpts ) {
                fewestOpts = onesCount;
                optsLocal  = i;
            } // End If
        } // End If
    } // End For

    if ( optsLocal != -1 )
        for ( j = 0; j < 10; j++ )
            zeroOptions[j] = pushGrid[optsLocal][j];

    return;
} // End deduce

int solve ( void ) {

    int i, repairs, zeroOptions[10];

    deduce ( zeroOptions );

    if ( zeroOptions[0] == -1 ) {
        printf ("Guesses: %d\n", guesses);
        return 1;
    } // End If

    for ( i = 1; i < 10; i++ ) {
        if ( zeroOptions[i] == 0 ) continue;

        myGrid[ zeroOptions[0] ] = i;

        guesses++;
        if ( solve() == 1 ) return 1;
        guesses--;
    } // End If

    myGrid[ zeroOptions[0] ] = 0;

    repairs = repairStack[ stackPtr-- ];

    for ( i = 0; i < repairs; i++ )
        myGrid[ repairStack[stackPtr--] ] = 0;

    return 0;
} // End Solve
