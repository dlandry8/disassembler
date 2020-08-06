*----------------------------------------------------------
* Input buffer
*----------------------------------------------------------
outputBuff      DC.B    '                                   ',0
newLine         DC.B    CR,LF,0
insertSpace     DC.B    ' ',0

*----------------------------------------------------------
* Prompts
*----------------------------------------------------------
lblStart        DC.B    'Please enter a starting address. ',0
lblEnd          DC.B    'Please enter an ending address. ',0
lblBadEndH      DC.B    'Address range is too high. ',0
lblBadEndL      DC.B    'Invalid address range. ',CR,LF,0
lblBadOrder     DC.B    'Input addresses are in the wrong order. ',CR,LF,0
pressEnter      DC.B    'Press enter to continue.',0
enterExit       DC.B    'Thank you for using our disassembler!',0
lblExitPrompt   DC.B    'End of memory range. Press 1 to repeat for new range.',0

*----------------------------------------------------------
* OpCodes
*----------------------------------------------------------
opcode_MOVE	    DC.B	'MOVE',0       *
opcode_MOVEM	DC.B	'MOVEM',0 *
opcode_NOP      DC.B    'NOP',0 *
opcode_MOVEA    DC.B    'MOVEA',0   *
opcode_MOVEQ    DC.B    'MOVEQ',0   *
opcode_ADD      DC.B    'ADD',0 *
opcode_ADDA     DC.B    'ADDA',0    *
opcode_ADDQ     DC.B    'ADDQ',0    *
opcode_SUB      DC.B    'SUB',0 *
opcode_MULS     DC.B    'MULS',0    *
opcode_DIVU     DC.B    'DIVU',0    *
opcode_LEA      DC.B    'LEA ',0 *
opcode_AND      DC.B    'AND',0 *
opcode_OR       DC.B    'OR',0  *
opcode_NOT      DC.B    'NOT',0 *
opcode_LSL      DC.B    'LSL',0 *
opcode_LSR      DC.B    'LSR',0 *
opcode_ASR      DC.B    'ASR',0 *
opcode_ASL      DC.B    'ASL',0 *
opcode_BGT      DC.B    'BGT ',0 
opcode_BLE      DC.B    'BLE ',0 
opcode_BEQ      DC.B    'BEQ ',0 
opcode_JSR      DC.B    'JSR ',0 *
opcode_RTS      DC.B    'RTS',0  *
opcode_BRA      DC.B    'BRA ',0 
BYTE            DC.B    '.B ',0  
WORD            DC.B    '.W ',0
LONG            DC.B    '.L ',0  
FAIL            DC.B    'Invalid Op-code.',0

*----------------------------------------------------------
* EA Building Blocks
*----------------------------------------------------------
EA_COMMA        DC.B    ',',0
EA_R_PAR        DC.B    ')',0
boo             DC.B    'DATA',0
Dn              DC.B    'D',0
An              DC.B    'A',0
neg_An          DC.B    '-(A',0
pos_An          DC.B    '(A',0
immediate       DC.B    '#',0
EA_0            DC.B    '0',0
EA_1            DC.B    '1',0
EA_2            DC.B    '2',0
EA_3            DC.B    '3',0
EA_4            DC.B    '4',0
EA_5            DC.B    '5',0
EA_6            DC.B    '6',0
EA_7            DC.B    '7',0
EA_8            DC.B    '8',0
EA_9            DC.B    '9',0
EA_A            DC.B    'A',0
EA_B            DC.B    'B',0
EA_C            DC.B    'C',0
EA_D            DC.B    'D',0
EA_E            DC.B    'E',0
EA_F            DC.B    'F',0

EA_SLASH        DC.B    '/',0
MOVEM_A0        DC.B    'A0',0
MOVEM_A1        DC.B    'A1',0
MOVEM_A2        DC.B    'A2',0
MOVEM_A3        DC.B    'A3',0
MOVEM_A4        DC.B    'A4',0
MOVEM_A5        DC.B    'A5',0
MOVEM_A6        DC.B    'A6',0
MOVEM_A7        DC.B    'A7',0
MOVEM_D0        DC.B    'D0',0
MOVEM_D1        DC.B    'D1',0
MOVEM_D2        DC.B    'D2',0
MOVEM_D3        DC.B    'D3',0
MOVEM_D4        DC.B    'D4',0
MOVEM_D5        DC.B    'D5',0
MOVEM_D6        DC.B    'D6',0
MOVEM_D7        DC.B    'D7',0







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
