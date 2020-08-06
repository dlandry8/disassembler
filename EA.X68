*-----------------------------------------------------------
* Title      :  EA Decompilation
* Written by :  Preston Mar
* Description:  Effective Address decompiler
*-----------------------------------------------------------

*EA Modes
*1 data register direct
*2 address register direct
*3 address register indirect
*4 immediate data
*5 addres register indirect with post incrementing
*6 address register indirect with pre decrementing
*7 absolute longword
*8 absolute word 

*IMPORTANT*
*HOW DATA IS PASSED IN/RETURNED
*A5 is opcode being passed in
*D0 for output
*D1 - used for immediate data
*D2 - used for immediate data
*D3 - used for immediate data
*D4 - return location of next opcode
*D5 - mode
*D6 - register
*D7 is for passing data between subroutines

*print when found



STAREA   
*SUBROUTINES FOR SIZE, MODE, AND REGISTER 

show0to2        *usually EA register      
                MOVE.W   (A5)+,D7                                            
                RTS

show3to5        *usually EA mode    
                MOVE.W   (A5)+,D7                                           
                RTS   

show6to8        *usually mode       
                MOVE.W   (A5)+,D7                                            
                RTS

show9to11       *usually register    
                MOVE.W   (A5)+,D7                                                         
                RTS             

INSERT_COMMA    *insert comma betwen source and dest
                MOVE.B  #14,D0
                LEA     EA_COMMA,A1
                TRAP    #15
                RTS

CONVERT_MODE_REG    *converts mode and register
                *first find mode
                *then output register
                CMP.W   #$0000,D5    *Dn
                BEQ     DATA_REG
                
                CMP.W   #$0001,D5    *An
                BEQ     ADD_REG
                
                CMP.W   #$0010,D5    *(An)
                BEQ     INDIRECT_REG
                
                CMP.W   #$0011,D5    *(An)+
                BEQ     INCREMENT_REG
                
                CMP.W   #$0100,D5    *-(An)
                BEQ     DECREMENT_REG
                
                CMP.W   #$0111,D5    *immediate
                BEQ     IMMEDIATE_REG
                RTS  
                
DATA_REG        *print D then the register
                LEA     Dn,A1
                MOVE.B  #14,D0
                TRAP    #15
                BSR     CONVERT_REG
                RTS      

ADD_REG         *print A then the register
                MOVE.B  #14,D0 
                LEA     An,A1
                TRAP    #15
                BSR     CONVERT_REG
                RTS      

INDIRECT_REG    *print (A then register then )
                MOVE.B  #14,D0
                LEA     pos_An,A1
                TRAP    #15
                BSR     CONVERT_REG
                MOVE.B  #14,D0
                LEA     EA_R_PAR,A1
                TRAP    #15
                RTS 

INCREMENT_REG   *print (A then reigster then )
                MOVE.B  #14,D0
                LEA     pos_An,A1
                TRAP    #15
                BSR     CONVERT_REG
                MOVE.B  #14,D0
                LEA     EA_R_PAR,A1
                TRAP    #15
                RTS  
                
DECREMENT_REG   *print -(A then register then )
                MOVE.B  #14,D0
                LEA     neg_An,A1
                TRAP    #15
                BSR     CONVERT_REG
                MOVE.B  #14,D0
                LEA     EA_R_PAR,A1
                TRAP    #15
                RTS
                
IMMEDIATE_REG   MOVE.B  #14,D0
                LEA     immediate,A1
                TRAP    #15
                BSR     GET_IMMEDIATE
                RTS

CONVERT_REG     *binary to deciaml, theres got to be a more efficient way to do this
                CMP.W       #$000,D6
                BEQ         NUM0

                CMP.W       #$001,D6
                BEQ         NUM1

                CMP.W       #$010,D6
                BEQ         NUM2

                CMP.W       #$011,D6
                BEQ         NUM3

                CMP.W       #$100,D6
                BEQ         NUM4

                CMP.W       #$101,D6
                BEQ         NUM5

                CMP.W       #$110,D6
                BEQ         NUM6

                CMP.W       #$111,D6
                BEQ         NUM7
                RTS
                
GET_IMMEDIATE   *find out what immediate value is
                *get size
                CMP.W       #$000,D6
                BEQ         IMM_WORD
                
                CMP.W       #$001,D6
                BEQ         IMM_LONG
                
                *CMP.W       #%100,D4
                *BEQ         IMM_
                RTS
                
IMM_WORD        CLR         D1
                MOVE.W      (A6)+,D1         
                BSR         PRINT_WORD
                RTS
                
IMM_LONG        BSR         IMM_WORD
                BSR         IMM_WORD
                RTS
                
*IMM_            
                *RTS

*D1 for passed in word to print       
*D2 for increment
*D3 for hexa
PRINT_WORD      MOVE.B      #12,D2
loop_print      MOVE.W      D1,D3
                LSR.W       D2,D3           *get corresponding hex value
                CMP.B       #$0,D3
                BEQ         NUM0
                CMP.B       #$1,D3
                BEQ         NUM1
                CMP.B       #$2,D3
                BEQ         NUM2
                CMP.B       #$3,D3
                BEQ         NUM3
                CMP.B       #$4,D3
                BEQ         NUM4
                CMP.B       #$5,D3
                BEQ         NUM5
                CMP.B       #$6,D3
                BEQ         NUM6
                CMP.B       #$7,D3
                BEQ         NUM7
                CMP.B       #$8,D3
                BEQ         OUTPUT_8
                CMP.B       #$9,D3
                BEQ         OUTPUT_9
                CMP.B       #$A,D3
                BEQ         OUTPUT_A
                CMP.B       #$B,D3
                BEQ         OUTPUT_B
                CMP.B       #$C,D3
                BEQ         OUTPUT_C
                CMP.B       #$D,D3
                BEQ         OUTPUT_D
                CMP.B       #$E,D3
                BEQ         OUTPUT_E
                CMP.B       #$F,D3
                BEQ         OUTPUT_F
                
                SUB.B       #4,D2
                CMP.B       #0,D2
                BGE         loop_print
                RTS
                
OUTPUT_8        MOVE.B      #14,D0
                LEA         EA_8,A1
                TRAP        #15
                RTS
OUTPUT_9        MOVE.B      #14,D0
                LEA         EA_9,A1
                TRAP        #15
                RTS
OUTPUT_A        MOVE.B      #14,D0
                LEA         EA_A,A1
                TRAP        #15
                RTS
OUTPUT_B        MOVE.B      #14,D0
                LEA         EA_B,A1
                TRAP        #15
                RTS
OUTPUT_C        MOVE.B      #14,D0
                LEA         EA_C,A1
                TRAP        #15
                RTS
OUTPUT_D        MOVE.B      #14,D0
                LEA         EA_D,A1
                TRAP        #15
                RTS
OUTPUT_E        MOVE.B      #14,D0
                LEA         EA_E,A1
                TRAP        #15
                RTS
OUTPUT_F        MOVE.B      #14,D0
                LEA         EA_F,A1
                TRAP        #15
                RTS
                
NUM0            *print 0
                MOVE.B  #14,D0
                LEA     EA_0,A1
                TRAP    #15
                RTS
                
NUM1            *print 1
                MOVE.B  #14,D0
                LEA     EA_1,A1
                TRAP    #15
                RTS
                
NUM2            *print 2
                MOVE.B  #14,D0
                LEA     EA_2,A1
                TRAP    #15
                RTS

NUM3            *print 3
                MOVE.B  #14,D0
                LEA     EA_3,A1
                TRAP    #15
                RTS
                
NUM4            *print 4
                MOVE.B  #14,D0
                LEA     EA_4,A1
                TRAP    #15
                RTS  

NUM5            *print 5
                MOVE.B  #14,D0
                LEA     EA_5,A1
                TRAP    #15
                RTS    

NUM6            *print 6
                MOVE.B  #14,D0
                LEA     EA_6,A1
                TRAP    #15
                RTS  

NUM7            *print 7
                MOVE.B  #14,D0
                LEA     EA_7,A1
                TRAP    #15
                RTS    

DETERMINE_IR    *used for LS/AS determining the i/r bit
                MOVE.L   #%0000000000100000,D6       ;Storing the mask to D6
                MOVE.L   (A5),D7                    ;Copying the input line to D7
                AND.L    D6,D7                      ;ANDING the Data
                LSR      #5,D7                      ;Shifting the irrelavant bits out the right side
                RTS    


ERROR
*handles bad inputs
                LEA     boo,A1
                TRAP    #15
                RTS

  

*NOP - no EA

*MOVE
MOVE_EA         *bits 0-2 source register
                *bits 3-5 source mode
                *bits 6-8 dest mode
                *bits 9-11 dest register
                *bits 12-13 size
                *D4 tells where next instruction is
                CLR     D4
                BSR     show3to5            *get source mode
                MOVE.L  D7,D5
                
                BSR     show0to2            *get source register
                MOVE.L  D7,D6
                
                BSR     CONVERT_MODE_REG    *convert the source mode/reg and output
                BSR     INSERT_COMMA
                
                BSR     show6to8            *get destination mode
                MOVE.L  D7,D2
                
                BSR     show9to11           *get destination register
                MOVE.L  D7,D3
                
                BSR     CONVERT_MODE_REG    *convert destination mode/reg and output
                RTS

*MOVEA - moves data to An
MOVEA_EA        *bits 0-2 source register
                *bits 3-5 source mode
                *bits 9-11 dest register
                *bits 12-13 size
                CLR     D4
                BSR     show3to5
                MOVE.L  D7,D5               *get source mode
                
                BSR show0to2    
                MOVE.L  D7,D6               *get source register
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$010,D5            *tell method it is an An
                BSR     show9to11   
                MOVE.L  D7,D6               *get dest register
                
                BSR CONVERT_MODE_REG
                RTS

                             
                
*MOVEQ - moves data to Dn
MOVEQ_EA        *bits 0-7 data to be moved
                *bits 9-11 register
                CLR     D4
                MOVE.B  #14,D0
                LEA     immediate,A1
                TRAP    #15
                *get data
                
                BSR     INSERT_COMMA

                MOVE.L  #%000,D5            *tell method its a Dn
                BSR     show9to11
                MOVE.L  D7,D6               *get dest register
                
                BSR     CONVERT_MODE_REG
                RTS

*TODO
*MOVEM
MOVEM_EA        *bits 0-2 EA register
                *bits 3-5 EA mode'
                CLR     D6
                MOVE.W  (A6)+,D6
                CMP.W   #$00,D5
                BEQ     MOVEM_LIST_EA
                CMP.W   #$01,D5
                BEQ     MOVEM_EA_LIST
                
                RTS
                
MOVEM_LIST_EA   CLR     D5
                MOVE.W  D6,D5
MOVEM_EA_A7     AND.W   #$8000,D5
                CMP.W   #$8000,D5
                BNE     MOVEM_EA_A6
                MOVE.B  #14,D0
                LEA     MOVEM_A7,A1
                TRAP    #15 
                
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15 
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A6     AND.W   #$4000,D5
                CMP.W   #$4000,D5
                BNE     MOVEM_EA_A5
                LEA     MOVEM_A6,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A5     AND.W   #$2000,D5
                CMP.W   #$2000,D5
                BNE     MOVEM_EA_A4
                LEA     MOVEM_A5,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A4     AND.W   #$1000,D5
                CMP.W   #$1000,D5
                BNE     MOVEM_EA_A3
                LEA     MOVEM_A4,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A3     AND.W   #$0800,D5
                CMP.W   #$0800,D5
                BNE     MOVEM_EA_A2
                LEA     MOVEM_A3,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A2     AND.W   #$0400,D5
                CMP.W   #$0400,D5
                BNE     MOVEM_EA_A1
                LEA     MOVEM_A2,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15     

                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A1     AND.W   #$0200,D5
                CMP.W   #$0200,D5
                BNE     MOVEM_EA_A0
                LEA     MOVEM_A1,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15   

                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_A0     AND.W   #$0100,D5
                CMP.W   #$0100,D5
                BNE     MOVEM_EA_D7
                LEA     MOVEM_A0,A1
                MOVE.B  #14,D0
                TRAP    #15  
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15

                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D7     AND.W   #$0080,D5
                CMP.W   #$0080,D5
                BNE     MOVEM_EA_D6
                LEA     MOVEM_D7,A1
                MOVE.B  #14,D0
                TRAP    #15     
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15 
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D6     AND.W   #$0040,D5
                CMP.W   #$0040,D5
                BNE     MOVEM_EA_D5
                LEA     MOVEM_D6,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D5     AND.W   #$0020,D5
                CMP.W   #$0020,D5
                BNE     MOVEM_EA_D4
                LEA     MOVEM_D5,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D4     AND.W   #$0010,D5
                CMP.W   #$0010,D5
                BNE     MOVEM_EA_D3
                LEA     MOVEM_D4,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D3     AND.W   #$0008,D5
                CMP.W   #$0008,D5
                BNE     MOVEM_EA_D2
                LEA     MOVEM_D3,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D2     AND.W   #$0004,D5
                CMP.W   #$0004,D5
                BNE     MOVEM_EA_D1
                LEA     MOVEM_D2,A1
                MOVE.B  #14,D0
                TRAP    #15 
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15               
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D1     AND.W   #$0002,D5
                CMP.W   #$0002,D5
                BNE     MOVEM_EA_D0
                LEA     MOVEM_D1,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15     

                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EA_D0     AND.W   #$0001,D5
                CMP.W   #$0001,D5
                BNE     MOVEM_EA_DONE
                LEA     MOVEM_D0,A1
                MOVE.B  #14,D0
                TRAP    #15           
MOVEM_EA_DONE   CLR     D5
                CLR     D6                
                RTS
                
MOVEM_EA_LIST   CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D0     AND.W   #$0001,D5
                CMP.W   #$0001,D5
                BNE     MOVEM_EAL_D1
                LEA     MOVEM_D0,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15 
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D1     AND.W   #$0002,D5
                CMP.W   #$0002,D5
                BNE     MOVEM_EAL_D2
                LEA     MOVEM_D1,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15  
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D2     AND.W   #$0004,D5
                CMP.W   #$0004,D5
                BNE     MOVEM_EAL_D3
                LEA     MOVEM_D2,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15   
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D3     AND.W   #$0008,D5
                CMP.W   #$0008,D5
                BNE     MOVEM_EAL_D4
                LEA     MOVEM_D3,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D4     AND.W   #$0010,D5
                CMP.W   #$0010,D5
                BNE     MOVEM_EAL_D5
                LEA     MOVEM_D4,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D5     AND.W   #$0020,D5
                CMP.W   #$0020,D5
                BNE     MOVEM_EAL_D6
                LEA     MOVEM_D5,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D6     AND.W   #$0040,D5
                CMP.W   #$0040,D5
                BNE     MOVEM_EAL_D7
                LEA     MOVEM_D6,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_D7     AND.W   #$0080,D5
                CMP.W   #$0080,D5
                BNE     MOVEM_EAL_A0
                LEA     MOVEM_D7,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15  
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A0     AND.W   #$0100,D5
                CMP.W   #$0100,D5
                BNE     MOVEM_EAL_A1
                LEA     MOVEM_A0,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A1     AND.W   #$0200,D5
                CMP.W   #$0200,D5
                BNE     MOVEM_EAL_A2
                LEA     MOVEM_A1,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15 
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A2     AND.W   #$0400,D5
                CMP.W   #$0400,D5
                BNE     MOVEM_EAL_A3
                LEA     MOVEM_A2,A1
                MOVE.B  #14,D0
                TRAP    #15   
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A3     AND.W   #$0800,D5
                CMP.W   #$0800,D5
                BNE     MOVEM_EAL_A4
                LEA     MOVEM_A3,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A4     AND.W   #$1000,D5
                CMP.W   #$1000,D5
                BNE     MOVEM_EAL_A5
                LEA     MOVEM_A4,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A5     AND.W   #$2000,D5
                CMP.W   #$2000,D5
                BNE     MOVEM_EAL_A6
                LEA     MOVEM_A5,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5    
MOVEM_EAL_A6     AND.W   #$4000,D5
                CMP.W   #$4000,D5
                BNE     MOVEM_EAL_A7
                LEA     MOVEM_A6,A1
                MOVE.B  #14,D0
                TRAP    #15
                LEA     EA_SLASH,A1
                MOVE.B  #14,D0
                TRAP    #15
                
                CLR     D5
                MOVE.W  D6,D5
MOVEM_EAL_A7     AND.W   #$8000,D5
                CMP.W   #$8000,D5
                BNE     MOVEM_EA_DONE1
                LEA     MOVEM_A7,A1
                MOVE.B  #14,D0
                TRAP    #15 
                
MOVEM_EA_DONE1  CLR     D5
                CLR     D6              
                RTS
                


*TODO
*ADD - determine if EA -> Dn or Dn -> EA
ADD_EA          CMP.W   #$00,D5
                BEQ     ADD_DN_EA
                CMP.W   #$11,D5
                BEQ     ADD_EA_DN
                RTS

ADD_EA_DN       *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 Dn register
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$000,D5
                BSR     show9to11
                MOVE.L  D7,D6               *get dest register
                
                BSR     CONVERT_MODE_REG
                RTS

ADD_DN_EA       CLR     D4
                MOVE.L  #$000,D5
                BSR     show9to11
                MOVE.L  D7,D6               *get dest register
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                RTS

*ADDA - ADD for An
ADDA_EA         *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 An register
                CLR     D4
                BSR     show3to5            *EA mode
                MOVE.L  D7,D5
                BSR     show0to2            *EA register
                MOVE.L  D7,D6
                
                BSR CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$001,D5            *set to An mode
                BSR     show9to11           *source register
                MOVE.L  D7,D6   
                BSR     CONVERT_MODE_REG
                
                RTS
                
*TODO
*ADDQ - ADD quick 
ADDQ_EA         *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 6-7 size
                CLR     D4
                MOVE.B  #14,D0
                LEA     immediate,A1
                TRAP    #15
                MOVE.W  (A5)+,D6
                
                
                BSR     INSERT_COMMA
                
                BSR     show3to5            *EA mode
                MOVE.L  D7,D5
                BSR     show0to2            *EA register
                MOVE.L  D7,D6
                
                BSR CONVERT_MODE_REG
                RTS
                
*TODO
*SUB - determine if its EA -> Dn or Dn -> EA
SUB_EA          CMP.W     #$01,D5
                BEQ     SUB_DN_EA
                CMP.W     #$11,D5
                BEQ     SUB_EA_DN
                RTS

SUB_EA_DN       *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 6-8 op mode
                *bits 9-11 Dn register
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5            
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #%000,D5            *set D5 to dn mode
                BSR     show9to11           
                MOVE.L  D7,D6               *get Dn register
                
                BSR     CONVERT_MODE_REG
                RTS
    
SUB_DN_EA       CLR     D4
                MOVE.L  #$000,D5            *set D5 to dn mode
                BSR     show9to11           
                MOVE.L  D7,D6               *get Dn register
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5            
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                RTS

*MULS
MULS_EA         *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 dest register
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA mode
                
                *error check             
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$000,D5            *set to Dn mode
                BSR     show9to11
                MOVE.L  D7,D6               *get dest register
                
                BSR     CONVERT_MODE_REG
                RTS

*DIVU
DIVU_EA         *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 register
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5        
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$000,D6            *set mode to Dn
                BSR     show9to11
                MOVE.L  D7,D5               *get dest register
                
                BSR     CONVERT_MODE_REG
                RTS
                
                

*LEA
LEA_EA          *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 An register
                CLR     D4
                                
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$001,D5            *set dest mode to An
                BSR     show9to11
                MOVE.L  D7,D6               *get dest register
                


                
                BSR     CONVERT_MODE_REG
                RTS
      
*TODO
*determines which AND to use          
AND_EA          CMP     #$00,D5
                BEQ     AND_DN_EA
                CMP     #$11,D5
                BEQ     AND_DN_EA
                RTS

*AND - AND      EA,Dn
AND_EA_DN       *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 6-8 OP mode
                *bits 9-11 Dn register
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5    
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG    
                BSR     INSERT_COMMA
                
                MOVE.L  #$000,D5            *set mode to Dn
                BSR     show9to11
                MOVE.L  D7,D6               *set register
                
                BSR     CONVERT_MODE_REG
                RTS
                
AND_DN_EA      *Dn,EA version  
                CLR     D4              
                MOVE.L  #$000,D5            *set mode to Dn
                BSR     show9to11
                MOVE.L  D7,D6               *set register
                
                BSR     CONVERT_MODE_REG    
                BSR     INSERT_COMMA
                
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5    
                MOVE.L  D7,D5               *get EA mode
                
                BSR     CONVERT_MODE_REG
                RTS
*TODO
*OR
OR_EA           *determine if its ea to dn or dn to ea
                RTS
                
OR_EA_DN        *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 9-11 dn register 
                *bits 6-8 op mode
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA Mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                BSR     show0to2
                MOVE.L  D7,D6               *get dest register
                BSR     show3to5            
                MOVE.L  D7,D5               *get dest Mode
                
                BSR     CONVERT_MODE_REG
                RTS
                
OR_DN_EA        CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get dest register
                BSR     show3to5            
                MOVE.L  D7,D5               *get dest Mode
                
                BSR     CONVERT_MODE_REG
                BSR     INSERT_COMMA
                
                MOVE.L  #$000,D5            *set mode
                BSR     show9to11
                MOVE.L  D7,D6               *set register
                
                BSR     CONVERT_MODE_REG
                
                RTS

*NOT
NOT_EA          *bits 0-2 EA register
                *bits 3-5 EA mode
                *bits 6-7 size
                CLR     D4
                BSR     show0to2
                MOVE.L  D7,D6               *get EA register
                BSR     show3to5
                MOVE.L  D7,D5               *get EA Mode
                
                BSR     CONVERT_MODE_REG
                RTS

*LSL - Assume direction is handled in opcode
LSL_EA          *bits 0-2 register      
                *bits 6-7 size
                *bits 9-11 count/register
                CLR     D4
                BSR     DETERMINE_IR
                
                CMP.W   #$1,D7              *if i/r is 1 display data register
                BEQ     LS_DN
                CMP.W   #$0,D7
                BEQ     LS_IMM              *if i/r is 0 display immediate
                
                BSR     show0to2
                MOVE.L  D7,D6               *register/shift
                BSR     CONVERT_REG         
                
                RTS

*LSR - assume direction is handled in opcode
LSR_EA          *bits 0-2 register      
                *bits 6-7 size
                *bits 9-11 count/register
                CLR     D4
                BSR     DETERMINE_IR
                
                CMP.W   #$1,D7              *if i/r is 1 display data register
                BEQ     LS_DN
                CMP.W   #$0,D7
                BEQ     LS_IMM              *if i/r is 0 display immediate
                
                BSR     show0to2
                MOVE.L  D7,D6               *register/shift
                BSR     CONVERT_REG    
                
                RTS

LS_DN           *output for Data register
                MOVE.B  #14,D0
                LEA     EA_D,A1
                TRAP    #15
                RTS
                
LS_IMM          *output for immediate data
                MOVE.B  #14,D0
                LEA     immediate,A1
                TRAP    #15
                RTS

*ASR - assume direction is handled in opcode
ASR_EA          *bits 0-2 register      
                *bits 6-7 size
                *bits 9-11 count/register
                CLR     D4
                BSR     DETERMINE_IR
                
                CMP.W   #$1,D7              *if i/r is 1 display data register
                BEQ     LS_DN
                CMP.W   #$0,D7
                BEQ     LS_IMM              *if i/r is 0 display immediate
                
                BSR     show0to2
                MOVE.L  D7,D6               *register/shift
                BSR     CONVERT_REG    
                
                RTS

*ASL - assume direction is handled in opcode
ASL_EA          *bits 0-2 register      
                *bits 6-7 size
                *bits 9-11 count/register
                BSR     DETERMINE_IR
                
                CMP.W   #$1,D7              *if i/r is 1 display data register
                BEQ     LS_DN
                CMP.W   #$0,D7
                BEQ     LS_IMM              *if i/r is 0 display immediate
                
                BSR     show0to2
                MOVE.L  D7,D6               *register/shift
                BSR     CONVERT_REG    
                
                RTS
                RTS


AS_DN           *output for dn data
                MOVE.B  #14,D0
                LEA     EA_D,A1
                TRAP    #15
                RTS

AS_IMM          *output for immediate dat
                MOVE.B  #14,D0
                LEA     immediate,A1
                TRAP    #15
                RTS

*JSR
JSR_EA          *bits 0-2 EA register
                *bits 3-5 EA mode
                CLR     D4
                BSR     show3to5            *EA mode
                MOVE.L  D7,D5
                BSR     show0to2            *EA register
                MOVE.L  D7,D6
                
                BSR CONVERT_MODE_REG
                RTS

*RTS - no EA
*BGT - no EA
*BLE - no EA
*BEQ - no EA
*BRA - no EA, print displacement

*messages



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
