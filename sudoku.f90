! Program: sudoku.f90
! Programmer: James Church
! Date: June 23, 2008
! Description: Given an input file of an unsolved sudoku puzzle
!              from the command line, this program will
!              solve the puzzle:

MODULE shared_data
    INTEGER, PARAMETER             :: GRID_SIZE  = 81
    INTEGER, PARAMETER             :: GRID_SHAPE = 9
    INTEGER, DIMENSION(GRID_SIZE)  :: grid
    INTEGER, DIMENSION(GRID_SIZE)  :: sector = &
                                       (/ 0,0,0,3,3,3,6,6,6, &
                                          0,0,0,3,3,3,6,6,6, &
                                          0,0,0,3,3,3,6,6,6, &
                                          27,27,27,30,30,30,33,33,33, &
                                          27,27,27,30,30,30,33,33,33, &
                                          27,27,27,30,30,30,33,33,33, &
                                          54,54,54,57,57,57,60,60,60, &
                                          54,54,54,57,57,57,60,60,60, &
                                          54,54,54,57,57,57,60,60,60 /)
END MODULE shared_data

PROGRAM sudoku
    USE shared_data

    LOGICAL :: success
    INTEGER :: i

    10 FORMAT (9I2)

    ! Read in the 81 elements
    DO i = 0, GRID_SHAPE-1
        READ (*,10) grid(i*GRID_SHAPE+1),&
                    grid(i*GRID_SHAPE+2),&
                    grid(i*GRID_SHAPE+3),&
                    grid(i*GRID_SHAPE+4),&
                    grid(i*GRID_SHAPE+5),&
                    grid(i*GRID_SHAPE+6),&
                    grid(i*GRID_SHAPE+7),&
                    grid(i*GRID_SHAPE+8),&
                    grid(i*GRID_SHAPE+9)
    END DO

    CALL solve(success)

    ! Write the solved grid to the screen
    DO i = 0, GRID_SHAPE-1
        WRITE (*,10) grid(i*GRID_SHAPE+1),&
                    grid(i*GRID_SHAPE+2),&
                    grid(i*GRID_SHAPE+3),&
                    grid(i*GRID_SHAPE+4),&
                    grid(i*GRID_SHAPE+5),&
                    grid(i*GRID_SHAPE+6),&
                    grid(i*GRID_SHAPE+7),&
                    grid(i*GRID_SHAPE+8),&
                    grid(i*GRID_SHAPE+9)
    END DO
END PROGRAM sudoku

! solve will solve an unsolved sudoku grid
! solve takes one output argument:
!     success - Boolean variable which will be true or false
!               depending on if this puzzle is solved or not
RECURSIVE SUBROUTINE solve(success)
    USE shared_data

    LOGICAL, INTENT(OUT)           :: success

    INTEGER                        :: min_count
    INTEGER                        :: min_local
    INTEGER                        :: zero_count
    INTEGER                        :: deductions
    INTEGER                        :: tally
    INTEGER, DIMENSION(GRID_SHAPE) :: possible
    INTEGER, DIMENSION(GRID_SIZE)  :: copy
    LOGICAL                        :: future_success
    INTEGER                        :: i

    success = .FALSE.

    deduction_loop: DO
        min_count = grid_shape + 1
        min_local = -1
        zero_count = 0
        deductions = 0

        element_check: DO i = 1,GRID_SIZE
            IF (grid(i) .NE. 0) CYCLE

            zero_count = zero_count + 1
            CALL getPossible(i, possible, tally)

            IF (tally .EQ. 0) THEN
                RETURN
            END IF

            IF (tally .EQ. 1) THEN
                grid(i) = possible(1)
                deductions = deductions + 1
            ELSE
                if (tally .LT. min_count) THEN
                    min_count = tally
                    min_local = i
                END IF
            END IF
        END DO element_check

        IF (deductions .EQ. 0) EXIT deduction_loop
    END DO deduction_loop

    IF (zero_count .EQ. 0) THEN
        success = .TRUE.
        RETURN
    END IF

    copy = grid
    CALL getPossible(min_local, possible, tally)

    DO i = 1,9
        IF (possible(i) .EQ. 0) EXIT

        grid(min_local) = possible(i)
        CALL solve(future_success)
        IF (future_success .EQV. .TRUE.) THEN
            success = .TRUE.
            EXIT
        END IF

        grid = copy
    END DO
END SUBROUTINE solve

! getPossible finds all of the possible values for an open location
! solve takes three arguments argument:
!    pos (input) - Integer Position of open square
!    possible (output) - Array of 9 elements containing the possible numbers
!                       (first open number at 1, second at 2, thrid at 3...)
!    tally (output) - Integer of total number of possible numbers
SUBROUTINE getPossible ( pos, possible, tally )
    USE shared_data

    INTEGER, INTENT(IN)                         :: pos
    INTEGER, DIMENSION(GRID_SHAPE), INTENT(OUT) :: possible
    INTEGER, INTENT(OUT)                        :: tally
    INTEGER                                     :: value
    INTEGER                                     :: i
    LOGICAL                                     :: found

    i = 1
    tally = 0

    DO value = 1,9
        CALL conflictFound (pos, value, found)

        IF (found .EQV. .FALSE.) THEN
            tally = tally + 1
            possible(i) = value
            i = i + 1
        END IF
    END DO

    ! The array position after last found value is given a zero
    IF (tally .NE. GRID_SHAPE) THEN
        possible(i) = 0
    END IF
END SUBROUTINE getPossible

! conflictFound is a boolean routine to find if a square has a conflict with value
! conflictFound has three arguments:
!    pos (input) - Integer Position of open square
!    value (input) - Integer value that we might find to conflict with open square
!    response (output) - Boolean value with true (conflict found) or false
!                        (conflict not found)
SUBROUTINE conflictFound ( pos, value, response )
    USE shared_data

    INTEGER, INTENT(IN)  :: pos
    INTEGER, INTENT(IN)  :: value
    LOGICAL, INTENT(OUT) :: response

    INTEGER :: row
    INTEGER :: col
    INTEGER :: sec
    INTEGER :: i

    row = (pos - 1) / GRID_SHAPE
    col = MOD(pos - 1, GRID_SHAPE)
    sec = sector(pos)

    response = .FALSE.

    ! Search all around this sector for a value
    IF (grid(sec+ 1) .EQ. value .OR. &
        grid(sec+ 2) .EQ. value .OR. &
        grid(sec+ 3) .EQ. value .OR. &
        grid(sec+10) .EQ. value .OR. &
        grid(sec+11) .EQ. value .OR. &
        grid(sec+12) .EQ. value .OR. &
        grid(sec+19) .EQ. value .OR. &
        grid(sec+20) .EQ. value .OR. &
        grid(sec+21) .EQ. value) THEN
        response = .TRUE.
    END IF

    DO i = 0, GRID_SHAPE-1
        IF (response .EQV. .TRUE.) EXIT

        ! Search this row for conflicts with value
        IF (grid(row*9+i+1) .EQ. value) THEN
            response = .TRUE.
        END IF

        ! Search this column for conflicts with value
        IF (grid(i*9+col+1) .EQ. value) THEN
            response = .TRUE.
        END IF
    END DO
END SUBROUTINE conflictFound
