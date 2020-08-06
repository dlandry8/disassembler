*-------------------------------------------------------------------------
* Title      :  I/O Subroutines
* Written by :  David Landry
* Date       :  10/29/2018
* Description:  The various I/O Subroutines:
*                   startPrompt: Gets user input for start & end addresses
*                                   and converts them into hex numbers.
*-------------------------------------------------------------------------

*-------------------------------------------------------------------------
*   Memory addresses:
*       A000    Holds the start address for the loaded program as a hex
*       A010    Holds the end address for the loaded program as a hex
*-------------------------------------------------------------------------

*-------------------------------------------------------------------------
*   Equates
*-------------------------------------------------------------------------
startAddress    EQU         $A000       * Starting address as a hex.
endAddress      EQU         $A010       * Ending address as a hex.
INPUT_S         EQU         2
INPUT_N         EQU         4
PRINT_S         EQU         14
CR              EQU         $0D
LF              EQU         $0A
minAddress      EQU         $1000       * Our program's starting address
maxAddress      EQU         $2300       * Our program's ending address
save_reg        REG         A0-A6/D0-D6 * Range of registers to save.
maxLines        EQU         30

*-------------------------------------------------------------------------
*   Strings
*-------------------------------------------------------------------------
                INCLUDE     'strings.x68'   

    ORG    $1000
START:                                  * first instruction of program
*-------------------------------------------------------------------------
*   Subroutine:     startPrompt
*   Written by:     David Landry
*   Description:    User prompt to get the start and end address to scan.
*   Registers:
*       A1, D0, D1  Temporary registers used with Trap functions.
*       A2, D2      Content and size of user input for start address.
*       A3, D3      Content and size of user input for end address.
*       A6          Starting address.
*       A5          Ending address
*       D2, D3      These are also the number of characters remaining
*                       in the user's input hex number. These get
*                       decremented as each hex digit gets processed.
*       D4          Holds a character of the user's input. Gets
*                       manipulated into a hex digit.
*       D5          A counter to determine the number of left shifts for
*                       the current hex digit.
*       D6          The full hex number to be built.
*-------------------------------------------------------------------------
* startPrompt gathers the user's input for start and end address and 
*   stores them in registers A2 and A3. The string character counters are
*   also stored in D2 and D3.
startPrompt:
            * D0 controls the I/O mode used with TRAP #15.
            * D1 is the string size of the user input, returned by TRAP#15
            * D2 is the preserved string size of this input. It will be
            *   used to determine how many hex digits are left to process.
            * A1 is the string I/O used by TRAP #15.
            * A2 is where the string starting address is stored (the
            *   user input for starting address).
            CLR         D6
            CLR         D2
            CLR         D3
            MOVE.B      #PRINT_S, D0        * Set Trap to print string
                                            *   mode.
            LEA         lblStart, A1        * Load the start address
                                            *   prompt into address
                                            *   register A1
            TRAP        #15                 * Print prompt.
            LEA         outputBuff, A1
            MOVE.B      #INPUT_S, D0        * Set Trap to input string
                                            *   mode.
            TRAP        #15                 * Get user input for
                                            *   starting address.
            MOVEA.L     A1, A2              * Copy address to the
                                            *   memory address 
                                            *   startAddrStr.
            MOVE.B      D1, D2              * Copies string size to D2.
            BRA         Iterate1            * Begin parsing user input
                                            *   for starting address.
            
endPrompt:
            * D0 controls the I/O mode used with TRAP #15.
            * D1 is the string size of the user input, returned by TRAP#15
            * D3 is the preserved string size of this input. It will be
            *   used to determine how many hex digits are left to process.
            * A1 is the string I/O used by TRAP #15.
            * A3 is where the string ending address is stored (the
            *   user input for ending address).
            MOVE.B      #PRINT_S, D0        * Set Trap to print string
                                            *   mode.
            LEA         lblEnd, A1          * Load the end address 
                                            *   prompt into address 
                                            *   register A1.
            TRAP        #15                 * Print the 2nd prompt.
            MOVEA.L     #endAddress, A1
            MOVE.B      #INPUT_S, D0        * Set Trap to input string
                                            *   mode.
            TRAP        #15                 * Get user input for 
                                            *   ending address.
            MOVEA.L     A1, A3              * Copy address
            MOVE.B      D1, D3              * Copies string size to D3.
            BRA         Iterate2            * Begin parsing user input
                                            *   for ending address.

*-------------------------------------------------------------------------
*   Get the start address
*-------------------------------------------------------------------------
* Iterate1 iterates through each ASCII character of the first user input,
*   converting them to a hex equivalent. It determines whether the
*   character is a number, uppercase letter, or lowercase letter.
Iterate1:
            * D4 is the hex digit being worked on.
            CLR.L       D4                  * Sets the value of D4 to 0.
                                            *   D4 is a holding space for
                                            *   each digit obtained from
                                            *   the user input.
            MOVE.B      (A2),D4             * Copies the value of the
                                            *   leftmost nyble from first
                                            *   input to D4.
            CMP.B       #$40,D4             * Checks if it's a letter.
            BGT         isLetter1           * Branches if it's a letter
            SUBI.B      #$30, D4            * Otherwise, subtract $30.
            BRA         SetDigit1           * Set the digit.

* isLetter1 adjusts the ASCII to match the correct hex digit.
isLetter1:
            * D4 is the hex digit being worked on.
            CMP.B       #$60,D4             * If the ASCII value is
                                            *   greater than $60, it's a
                                            *   lowercase letter.
            BGT         Lowercase1          * In this case, branch to
                                            *   Lowercase1.
            SUBI.B      #$37, D4            * Since it's uppercase, 
                                            *   subtract $37 to get the
                                            *   correct hex value.
            BRA         SetDigit1           * Branch to SetDigit1 to set
                                            *   it into the correct place
                                            *   in the number.

* Lowercase1 adjusts the ASCII to match the correct hex digit if the ASCII
*   is a lowercase letter.
Lowercase1:
            * D4 is the hex digit being worked on.  
            SUBI.B      #$57, D4            * Subtract $57 to get the 
                                            *   correct hex value.
            BRA         SetDigit1           * Branch to SetDigit1 to set 
                                            *   it into the correct place
                                            *   in the number.

* The correct hex digit is now stored in register D4. SetDigit1 is the
*   continuation of Iterate1.
SetDigit1:
            * D2 is the number of hex digits not yet processed.
            * D5 will be a shift counter.
            SUBQ        #1, D2              * Subtract 1 from D2 which 
                                            *   counts the number of
                                            *   digits in reserve.
            CMP         #0, D2              * If there are no more digits
                                            *   in reserve, then this 
                                            *   digit is the last one, so
                                            *   no shifting is required.
            BEQ         SetNumber1          * If D1 is 0, branch to 
                                            *   SetNumber.
            CLR         D5                  * D5 is a counter, so
                                            *   initialize it to 0.

* LeftShift1 continuously shifts the current digit left 4 bits (1 hex
*   digit) until it is in the correct position in the hex number.
LeftShift1:
            * D4 contains the hex digit
            * D5 is an up-counter that controls left shifting.
            * D2 is the number of hex digits not yet processed.
            LSL.L       #4, D4              * Shift left 1 nyble.
            ADDQ        #1, D5              * Add 1 to the shift counter.
            CMP         D5, D2              * If the shift counter equals
                                            *   the digits-in-reserve
                                            *   counter, then no 
                                            *   additional shifting is 
                                            *   needed.
            BNE         LeftShift1          * Otherwise, loop back to
                                            *   LeftShift.
            
* SetNumber1 adds the current digit to the overall hex number.
SetNumber1: 
            * D4 contains the hex digit in the correct position relative
            *   to the whole hex number.
            * D6 contains the hex number being constructed.
            ADD.L       D4, D6              * Add the shifted longword to
                                            *   D6, which contains the 
                                            *   complete input number.
            CMP         #0, D2              * If there are no more digits
                                            *   in reserve, then we can
                                            *   save the number to memory.
            BEQ         SaveNumber1         * Move on to the next part if
                                            *   there are no more digits
                                            *   to get from input.
            ADDQ        #1, A2              * Otherwise, point A2 to the
                                            *   next ASCII character from
                                            *   the user input.
            BRA         Iterate1            * Return to Iterate1 to add
                                            *   the next digit to our
                                            *   desired hex number.

* SaveNumber1 saves the starting address to the address labeled
*   startAddress and resets D6 (the hex number).
SaveNumber1:
            * D6 is the hex number to be saved.
            * A6 is the starting address.
            CMP.L       #maxAddress, D6     * Compares with maxAddress
            BLT         checkRange11
            BRA         checkRange21
checkRange11:
            * D6 is the hex number to be saved.
            CMP.L       #minAddress, D6
            BGT         errorEndL
            BRA         SNContinue1
checkRange21:
            * D6 is the hex number to be saved.
            CMP.L       #minAddress, D6     * Compares with maxAddress
            BGT         checkRange31
            BRA         SNContinue1
checkRange31:
            * D6 is the hex number to be saved.
            CMP.L       #maxAddress, D6
            BLT         errorEndL
            BRA         SNContinue1
SNContinue1:
            * D6 is the hex number to be saved.
            * A6 is the starting address.
            MOVE.L      D6, startAddress    * Save the hex number to the
                                            *   memory address named
                                            *   startAddress ($A000).
            MOVEA.L     D6, A6
            CLR.L       D6                  * Reset D6 for the ending
                                            *   address.
            BRA         endPrompt           * Get the ending address.

*-------------------------------------------------------------------------
*   Get the end address
*-------------------------------------------------------------------------
* Iterate2 iterates through each ASCII character of the second user input,
*   converting them to a hex equivalent. It determines whether the
*   character is a number, uppercase letter, or lowercase letter.
Iterate2:
            * D4 is the hex digit to be worked on.
            * A3 is the address of the user's input.
            CLR.L       D4                  * Sets the value of D4 to 0.
                                            *   D4 is a holding space for
                                            *   each digit obtained from
                                            *   the user input.
            MOVE.B      (A3),D4             * Copies the value of the
                                            *   leftmost nyble from first
                                            *   input to D4.
            CMP.B       #$40,D4             * Checks if it's a letter.
            BGT         isLetter2           * Branches if it's a letter
            SUBI.B      #$30, D4            * Otherwise, subtract $30.
            BRA         SetDigit2

* isLetter2 adjusts the ASCII to match the correct hex digit.
isLetter2:
            * D4 is the hex digit being analyzed.
            CMP.B       #$60,D4             * If the ASCII value is
                                            *   greater than $60, it's a
                                            *   lowercase letter.
            BGT         Lowercase2          * In this case, branch to
                                            *   Lowercase1.
            SUBI.B      #$37, D4            * Since it's uppercase, 
                                            *   subtract $37 to get the
                                            *   correct hex value.
            BRA         SetDigit2           * Branch to SetDigit1 to set
                                            *   it into the correct place
                                            *   in the number.

* Lowercase2 adjusts the ASCII to match the correct hex digit if the ASCII
*   is a lowercase letter.
Lowercase2:            
            * D4 is the hex digit being analyzed.
            SUBI.B      #$57, D4            * Subtract $57 to get the 
                                            *   correct hex value.
            BRA         SetDigit2           * Branch to SetDigit1 to set 
                                            *   it into the correct place
                                            *   in the number.

* The correct hex value is now stored in register D4. SetDigit2 is the
*   continuation of Iterate2.
SetDigit2:
            * D3 is the number of hex digits still to be processed.
            * D5 is an up-counter used for hex character shifting.
            SUBQ        #1, D3              * Subtract 1 from D3 which 
                                            *   counts the number of
                                            *   digits in reserve.
            CMP         #0, D3              * If there are no more digits
                                            *   in reserve, then this 
                                            *   digit is the last one, so
                                            *   no shifting is required.
            BEQ         SetNumber2          * If D1 is 0, branch to 
                                            *   SetNumber.
            CLR          D5                 * D5 is a counter, so
                                            *   initialize it to 0.

* LeftShift2 continuously shifts the current digit left 4 bits until it is
*   in the correct position in the hex number.
LeftShift2:
            * D4 is the hex character being shifted.
            * D3 is the number of characters still to be processed.
            * D5 is the counter used to determine the number of shifts.
            LSL.L       #4, D4              * Shift left 1 nyble.
            ADDQ        #1, D5              * Add 1 to the shift counter.
            CMP         D5, D3              * If the shift counter equals
                                            *   the digits-in-reserve
                                            *   counter, then no 
                                            *   additional shifting is 
                                            *   needed.
            BNE         LeftShift2          * Otherwise, loop back to
                                            *   LeftShift.
            
* SetNumber2 adds the current digit to the overall hex number.
SetNumber2: 
            * D4 is the hex digit to be placed into the number.
            * D6 is the hex number being built.
            * D3 is the number of digits remaining to be inserted.
            * A3 is the location of the user input. Specifically, it is
            *   the nybble being considered currently.
            ADD.L       D4, D6              * Add the shifted longword to
                                            *   D6, which contains the 
                                            *   complete input number.
            CMP         #0, D3              * If there are no more digits
                                            *   in reserve, then we can
                                            *   save the number to memory.
            BEQ         SaveNumber2         * Move on to the next part if
                                            *   there are no more digits
                                            *   to get from input.
            ADDQ        #1, A3              * Otherwise, point A3 to the
                                            *   next ASCII character from
                                            *   the user input.
            BRA         Iterate2            * Return to Iterate1 to add
                                            *   the next digit to our
                                            *   desired hex number.

* SaveNumber2 saves the starting address to the address labeled
*   endAddress after range checking.
SaveNumber2:
            * D6 is the hex number.
            * D7 is a counter for the number of lines of display.
            * A6 is the starting address.
            * A5 is the ending address.
            CMP.L       #maxAddress, D6     * Compares with maxAddress
            BLT         checkRange12
            BRA         checkRange22
checkRange12:
            CMP.L       #minAddress, D6
            BGT         errorEndL
            BRA         checkRange22
checkRange22:
            CMP.L       #minAddress, D6     * Compares with maxAddress
            BGT         checkRange32
            BRA         checkRange42
checkRange32:
            CMP.L       #maxAddress, D6
            BLT         errorEndL
            BRA         checkRange42
checkRange42:
            CMP.L       #minAddress, A6
            BLT         checkRange52
            BRA         checkOrder2
checkRange52:
            CMP.L       #maxAddress, D6
            BGT         errorEndL
            BRA         checkOrder2
checkOrder2:
            * Check if ending address is less than starting address.
            CMP.L       startAddress, D6
            BLT         errorOrder
            * Otherwise, the end address is safe, so save it.
            MOVE.L      D6, A5              * Save the hex number to the
                                            *   memory address A5.
            CLR         D7                  * Clear register D7 to use it
                                            *   for line counting.
            BRA         opcodeLoop          * Branch to opcodeLoop to
                                            *   exit the subroutine.

*-------------------------------------------------------------------------
* Error Handling section.
*-------------------------------------------------------------------------
errorEndL:
            LEA         lblBadEndL, A1      * Loads error message to A1
            MOVE.B      #PRINT_S, D0        * Print string mode.
            TRAP        #15
            BRA         startPrompt

errorOrder:
            LEA         lblBadOrder, A1     * Loads error message to A1
            MOVE.B      #PRINT_S, D0        * Print string mode.
            TRAP        #15
            BRA         startPrompt

*-------------------------------------------------------------------------
* Opcode Loopthrough. Go through each chunk of data, translate to opcodes,
*   and print the result code by code and EA by EA.
*-------------------------------------------------------------------------
* 00000000000000000000000000000000
* 00000000000000000000000000001111
opcodeLoop:
            MOVE.L      #8, D1
            MOVE.L      #$F0000000, D2
            MOVEA.L     #outputBuff, A1
            MOVE.L      A6, D6
opcodeLoop2:
            CLR.L       D3
            MOVE.L      D6, D4
            AND.L       D2, D4
shiftOutput:
            CMP.L       D3, D1
            BGT         shiftOutput2
            BRA         shiftMask
shiftOutput2:
            ADD.L       #1, D3
            CMP.L       D3, D1
            BEQ         shiftMask
            LSR.L       #4, D4
            BRA         shiftOutput2
shiftMask:
            SUB.L       #1, D1
            LSR.L       #4, D2
checkDigitOutput:
            CMP.B       #$9, D4
            BGT         isUpperOutput
            ADD.B       #$30, D4
            BRA         displayLine
isUpperOutput:
            SUB.B       #$9, D4
            ADD.B       #$40, D4

displayLine:
            MOVE.B      D4, (A1)+
            CMP         #0, D1
            BGT         opcodeLoop2
            MOVE.B      #0, (A1)
            LEA         outputBuff, A1
            MOVE.L      #PRINT_S, D0
            TRAP        #15
            LEA         insertSpace, A1
            TRAP        #15
            JSR         STARTOP             * Run the next memory chunk
                                            *   through the opcode
                                            *   subroutine.
            MOVE.L      #PRINT_S, D0
            LEA         newLine, A1
            TRAP        #15
            ADDQ        #1, D7
            CMP         #maxLines, D7       * Prompt to press enter if
                                            *   the max # of lines have
                                            *   been printed to the
                                            *   console.
            BNE         checkToLoopBack
            MOVE.L      #PRINT_S, D0
            LEA         pressEnter, A1
            TRAP        #15
            LEA         outputBuff, A1      * Point A1 to our buffer
                                            *   space.
            MOVE.L      #INPUT_S, D0
            TRAP        #15
            CLR         D7
checkToLoopBack:
            CMP.L       A5, A6              * Check if we've arrived at
                                            *   the end address. If not,
                                            *   loop back and take in
                                            *   the next code.
            BLT         opcodeLoop
            BRA         exitPrompt
            

            INCLUDE     'OpcodeSubroutine.X68'  * Code to translate to 
                                                *   Opcode.

*-------------------------------------------------------------------------
*   End the program (or crash the program)
*   For when it comes crashing down and it hurts inside.
*-------------------------------------------------------------------------
exitPrompt:
            MOVE.L      #PRINT_S, D0
            LEA         lblExitPrompt, A1
            TRAP        #15
            MOVE.L      #INPUT_N, D0
            TRAP        #15
            CMP         #1, D1
            BNE         crash2
            MOVE.W      #$FF00, D1
            MOVE.L      #11, D0
            TRAP        #15
            BRA         startPrompt
crash2:
            MOVE.L      #PRINT_S, D0
            LEA         enterExit, A1
            TRAP        #15
            END         START               * Obligatory declaration of
                                            *   the last line of source.




























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
