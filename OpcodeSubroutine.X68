*-----------------------------------------------------------
* Title      : Decomposition Project Op-code section
* Written by : Enbai Kuang
* Date       :
* Description:
*-----------------------------------------------------------

STARTOP 
STROP    MOVE.W      (A6)+,D2    
        MOVEM.L     D0-D7/A0-A5, -(SP) 
        MOVE.W      #$2500,A5               
        MOVE.W      A5,A4       
        
        MOVE.W      #$4E71,D3   * check if NOP
        CMP.W       D2,D3   
        BEQ         NOP 
        
        MOVE.W      #$4E75,D3  *check if RTS 
        CMP.W       D2,D3   
        BEQ         RTS 
        
        MOVE.W      D2,D3     * uses d3 for shift
        ROL.W       #8,D3     * shifts the first two hex to last 2
        
        CMP.B       #$4E,D3   * machine code for JSR
        BEQ         JSR 
        CMP.B       #$45,D3 * check for NOT 
        BEQ         NOT 
        CLR.L       D3  
        
        MOVE.W      D2,D5   
        MOVE.B      #4,D4   
        JSR         LOOP    *  this should result in first 4 bits in d3
        CMP.W       #$0100,D3  * checks to see if LEA or MOVE
        BEQ         CHECK   
        BRA         SKIPCHK
        
CHECK     
        CLR.L       D3
        CLR.L       D4 
        MOVE.B      #3,D4   
        JSR         LOOP * the next three bits for register or DR
        ASL.W       #1,D2   
        BCS         LEA     * next bit should be 1 for lea
        BRA         MOVEM   * and 0 for movem
        
SKIPCHK
          MOVE.W    D5,D2   * check for move and movea
          CLR.L     D3
          CLR.L     D4  
          MOVE.B    #2,D4   
          JSR       LOOP        
          CMP.B     #$00,D3    
          BEQ       MOVECHK
          BRA       SKIPMV
          
MOVECHK      
        MOVE.B      #2,D4   * gets the size
        CLR.L       D3  
        JSR         LOOP        
        CLR.L       D5  
        MOVE.B      D3,D5

        MOVE.B      #3,D4 
        CLR.L       D3    
        JSR         LOOP    
        MOVE.W      D3,(A4)+  * destination reg     
        
        MOVE.B      #3,D4   * next three bits should be 001
        CLR.L       D3  
        JSR         LOOP    * for movea
        CMP.W       #$001,D3    
        BEQ         MOVEA   
        BRA         MOVE       
        
SKIPMV      
        MOVE.W      D5,D2   
        CLR.L       D3
        CLR.L       D4  
        MOVE.B      #4,D4   
        JSR         LOOP    
        CMP.W       #$0101,D3    
        BEQ         ADDQ    
        CMP.W       #$0111,D3   
        BEQ         MOVEQ   
        CMP.W       #$1001,D3   
        BEQ         SUB 
        CMP.W       #$1000,D3   
        BEQ         DOCHK   
        CMP.W       #$1100,D3   
        BEQ         MACHK   
        CMP.W       #$1101,D3   
        BEQ         ADCHK  
        CMP.W       #$1110,D3   
        BEQ         SHFTCHK
        CMP.W       #$0110,D3    
        BEQ         BCCHK
 
INVALID   MOVE.B        #14,D0   
        LEA         FAIL,A1 
        TRAP        #15 
        BRA         BACK    

BACK    
        MOVEM.L     (SP)+,D0-D7/A0-A5  
        RTS   

BCCHK    *checks for BGT, BLE, and BEQ
        MOVE.B      #4,D4  
        CLR.L       D3   
        JSR         LOOP   
        CMP.W       #$0000,D3   
        BEQ         BRA  
        CMP.W       #$0111,D3   
        BEQ         BEQ 
        CMP.W       #$1110,D3   
        BEQ         BGT 
        CMP.W       #$1111,D3   
        BEQ         BLE 
        BRA         INVALID 

DOCHK     * checks for divu and or
        MOVE.B      #3,D4   
        JSR         LOOP    
        MOVE.W      D3,(A4)+    *register  
        CLR.L        D3   
        MOVE.B      #3,D4   
        JSR         LOOP    
        CMP.W       #$011,D3    
        BEQ         DIVU  
        BRA         OR  
        
MACHK       
        MOVE.B      #3,D4   
        JSR         LOOP    
        MOVE.W      D3,(A4)+    *register   
        CLR.L       D3  
        MOVE.B      #3,D4   
        JSR         LOOP    
        CMP.W       #$111,D3    * checks for MULS & AND
        BEQ         MULS    
        BRA         AND 

ADCHK     
        MOVE.B      #3,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.W      D3,(A4)+    *register
        
        CLR.L       D3  
        MOVE.B      #3,D4   
        JSR         LOOP    
        
        CMP.W       #$011,D3    
        BEQ         ADDA
        CMP.W       #$111,D3    
        BEQ         ADDA    
        BRA         ADD 
        
SHFTCHK
        MOVE.B      #3,D4  
        CLR.L       D3   
        JSR         LOOP    
        MOVE.W      D3,D7    * count/register
        
        MOVE.B      #1,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.B      D3,D5   * stores direction for later
    
        MOVE.B      #2,D4   
        CLR.L        D3  
        JSR         LOOP        
        MOVE.B      D3,D6   * Stores size for later
        
        CMP.B       #$11,D3 * memory shifts 
        BEQ         SHFTMEM 
        
        MOVE.B      #1,D4   
        CLR.L         D3    
        JSR         LOOP    
        MOVE.W      D3,(A4)+    *I/R    
        
        ASL.W       #2,D2   
        BCS         LS
        BRA         AS
        
SHFTMEM 
        MOVE.B      #3,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.W      D7,(A4)+    
        MOVE.W      D5,(A4)+    
        MOVE.W      D6,(A4)+    
        CMP.W       #$000,D7        
        BEQ         AS 
LS
        CMP.B       #$0,D5
        BEQ         LSR
        BRA         LSL
AS      
        CMP.B       #$0,D5
        BEQ         ASR
       BRA       ASL
*---------------------------OPCODES------------------------------        
NOP
        MOVE.B      #14,D0  
        LEA         opcode_NOP,A1   
        TRAP        #15 
        
        BRA         BACK
*----------------------------------------------------------------
MOVE
        MOVE.B      #14,D0  
        LEA         opcode_MOVE,A1     
        TRAP        #15 
        
        MOVE.W      D3,(A4)+   * destination mode
        
        CMP.B       #$01,D5  
        BEQ         MBYT
        CMP.B       #$11,D5  
        BEQ         MWRD   
 
        MOVE.B      #14,D0  
        LEA         LONG,A1      
        TRAP        #15 
        BRA         SKP1    
MBYT      MOVE.B      #14,D0  
        LEA         BYTE,A1       
        TRAP        #15     
        BRA         SKP1    
MWRD      MOVE.B      #14,D0  
        LEA         WORD,A1       
        TRAP        #15 
SKP1      MOVE.B         #3,D4  
          CLR.L          D3 
          JSR            LOOP   
          MOVE.W         D3,(A4)+   *Source mode
          
          MOVE.B         #3,D4  
          JSR            LOOP   
          MOVE.W         D3,(A4)+   *Source des
          
          JSR         MOVE_EA
          BRA         BACK
*----------------------------------------------------------------       
MOVEA
        MOVE.B      #14,D0  
        LEA         opcode_MOVEA,A1      
        TRAP        #15 
        
        CMP.B       #$11,D5  
        BEQ         MAWRD   * for size word
        MOVE.B      #14,D0  * for size long
        LEA         LONG,A1      
        TRAP        #15 
        BRA         SKP2    

MAWRD     MOVE.B      #14,D0  
        LEA         WORD,A1      
        TRAP        #15 

SKP2      MOVE.B         #3,D4  
        CLR.L          D3   
        JSR            LOOP   
        MOVE.W         D3,(A4)+   *Source mode
          
        MOVE.B         #3,D4  
        CLR.L          D3   
        JSR            LOOP   
        MOVE.W         D3,(A4)+   *Source des
        
        JSR         MOVEA_EA
        BRA         BACK
*---------------------------------------------------
MOVEQ
        MOVE.B      #14,D0  
        LEA         opcode_MOVEQ,A1       
        TRAP        #15 
        
        MOVE.B      #3,D4    
        CLR.L       D3   
        JSR         LOOP    
        MOVE.W      D3,(A4)+    *register
        
        ASL.W       #1,D2   
        MOVE.B      #8,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.L      D3,(A4)+   * Data       

        JSR         MOVEQ_EA
        BRA         BACK
*---------------------------------------------------
MOVEM
        MOVE.B      #14,D0  
        LEA         opcode_MOVEM,A1       
        TRAP        #15 

        ASL.W   #2,D3   
        BCS     DR1
        MOVE.W  #00,D5      
        BRA     DR0 
DR1       MOVE.W  #01,D5     * this is the direction
DR0       ASL.W   #2,D2    
        BCS     MOVEML  * size is long = 1
        MOVE.B      #14,D0  
        LEA         WORD,A1   * size = 0
        TRAP        #15
        BRA         MOVEMW  
MOVEML    MOVE.B      #14,D0  
        LEA         LONG,A1   
        TRAP        #15
MOVEMW    CLR         D4  
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the mode
        
        CLR         D4  
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the register

        JSR         MOVEM_EA
        BRA         BACK
*---------------------------------------------------
ADD
        MOVE.B      #14,D0  
        LEA         opcode_ADD,A1        
        TRAP        #15 
        
        CMP.W       #$000,D3    
        BEQ         ADIR1        
        CMP.W       #$001,D3 
        BEQ         ADIR1       
        CMP.W       #$010,D3 
        BEQ         ADIR1   
        CMP.W       #$100,D3    
        BEQ         ADIR2       
        CMP.W       #$101,D3    
        BEQ         ADIR2       
        CMP.W       #$110,D3
        BEQ         ADIR2   
ADIR1   MOVE.W      #$00,D5   * DN - EA Direction
        CMP.W       #$000,D3    
        BEQ         ADBYT           
        CMP.W       #$001,D3 
        BEQ         ADWRD          
        CMP.W       #$010,D3 
        BEQ         ADLNG        
ADIR2   MOVE.W      #$11,D5   * EA - DN Direction 
        CMP.W       #$100,D3      
        BEQ         ADBYT           
        CMP.W       #$101,D3    
        BEQ         ADWRD          
        CMP.W       #$110,D3    
        BEQ         ADLNG  
ADBYT     MOVE.B      #14,D0  
        LEA         BYTE,A1           
        TRAP        #15 
        BRA         ACONT   
ADWRD     MOVE.B      #14,D0  
        LEA         WORD,A1           
        TRAP        #15 
        BRA         ACONT   
ADLNG     MOVE.B      #14,D0  
          LEA         LONG,A1          
          TRAP        #15 
ACONT   
        MOVE.W      D5,(A4)+    * direction 
        MOVE.W      D3,(A4)+    * opmode
        
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the mode
        
        CLR         D4  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the register

        JSR         ADD_EA
        BRA         BACK
*---------------------------------------------------
ADDA
        MOVE.B      #14,D0  
        LEA         opcode_ADDA,A1          
        TRAP        #15 
        
        MOVE.W      D3,(A4)+    *opmode
        CMP.W       #$011,D3    
        BEQ         ADAWRD  
        MOVE.B      #14,D0  
        LEA         LONG,A1 
        TRAP        #15 
        BRA         ADACONT 
ADAWRD  
        MOVE.B      #14,D0  
        LEA         WORD,A1 
        TRAP        #15 
ADACONT     
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the mode
        
        CLR         D4  
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the register
   
        JSR         ADDA_EA
        BRA         BACK
*---------------------------------------------------
ADDQ
        MOVE.B      #14,D0  
        LEA         opcode_ADDQ,A1         
        TRAP        #15 
        
        MOVE.W      #3,D4
        CLR.L       D3  
          JSR         LOOP
          MOVE.W      D3,(A4)+      * data
        
        ASL.W       #1,D2   * extra bit, should be 0
        MOVE.W      #2,D4   * size
        CLR.L       D3  
        JSR         LOOP
        
        CMP.B       #$00,D3 
        BEQ         ABYT    
        CMP.B       #$01,D3 
        BEQ         AWRD    
        MOVE.B      #14,D0  
        LEA         LONG,A1         
        TRAP        #15    
        BRA         ALNG    
ABYT      MOVE.B      #14,D0  
        LEA         BYTE,A1         
        TRAP        #15
        BRA         ALNG    
AWRD      MOVE.B      #14,D0  
        LEA         WORD,A1        
        TRAP        #15
ALNG      
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * ea mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+ * ea register
        
        JSR         ADDQ_EA
        BRA         BACK
*---------------------------------------------------
SUB
        MOVE.B      #14,D0  
        LEA         opcode_SUB,A1       
        TRAP        #15 

        CLR.L       D3  
        MOVE.B      #3,D4   
        JSR         LOOP 
        MOVE.W      D3,(A4)+  * register
        CLR.L       D3  
        
        MOVE.B      #3,D4   
        JSR         LOOP   
        CMP.W       #$011,D3 
        BEQ         SWRD    
        CMP.W       #$111,D3 
        BEQ         SLNG       
        CMP.W       #$000,D3    
        BEQ         SDIR1    
        CMP.W       #$001,D3 
        BEQ         SDIR1    
        CMP.W       #$010,D3 
        BEQ         SDIR1 
        CMP.W       #$100,D3    
        BEQ         SDIR2   
        CMP.W       #$101,D3    
        BEQ         SDIR2    
        CMP.W       #$110,D3
        BEQ         SDIR2  
SDIR1   MOVE.W      #$01,D5   * DN - EA Direction
        CMP.W       #$000,D3    
        BEQ         SBYT        
        CMP.W       #$001,D3 
        BEQ         SWRD        
        CMP.W       #$010,D3 
        BEQ         SLNG          
SDIR2   MOVE.W      #$11,D5   * EA - DN Direction
        CMP.W       #$100,D3    
        BEQ         SBYT       
        CMP.W       #$101,D3    
        BEQ         SWRD       
        CMP.W       #$110,D3
        BEQ         SLNG         
SBYT     MOVE.B      #14,D0     
        LEA         BYTE,A1           
        TRAP        #15 
        BRA         SCONT       
SWRD     MOVE.B      #14,D0      
        LEA         WORD,A1           
        TRAP        #15 
        BRA         SCONT   
SLNG     MOVE.B      #14,D0     
          LEA         LONG,A1          
          TRAP        #15   
SCONT     
        MOVE.W      D5,(A4)+           
        MOVE.W      D3,(A4)+    *OPmode
        
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg
        
        JSR         SUB_EA
        BRA         BACK
*---------------------------------------------------
MULS
        MOVE.B      #14,D0  
        LEA         opcode_MULS,A1            
        TRAP        #15

        MOVE.B      #14,D0  
        LEA         WORD,A1            
        TRAP        #15
        
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg

        JSR         MULS_EA
        BRA         BACK
*---------------------------------------------------
DIVU
        MOVE.B      #14,D0  
        LEA         opcode_DIVU,A1           
        TRAP        #15
        
        MOVE.B      #14,D0  
        LEA         WORD,A1            
        TRAP        #15

        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg

        JSR         DIVU_EA
        BRA         BACK
*---------------------------------------------------
LEA
        MOVE.B      #14,D0  
        LEA         opcode_LEA,A1       
        TRAP        #15
        
        MOVE.W      D3,(A4)+       
        ASL.W       #2,D2   * skips last 2 bits before ea
        
        CLR         D4  
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+ * this should be the register
        
        JSR         LEA_EA
        BRA         BACK

*---------------------------------------------------
AND
        MOVE.B      #14,D0  
        LEA         opcode_AND,A1       
        TRAP        #15 
            
        CMP.W       #$000,D3    
        BEQ         ANDIR1             
        CMP.W       #$001,D3 
        BEQ         ANDIR1             
        CMP.W       #$010,D3 
        BEQ         ANDIR1        
        CMP.W       #$100,D3    
        BEQ         ANDIR2            
        CMP.W       #$101,D3    
        BEQ         ANDIR2      
        CMP.W       #$110,D3
        BEQ         ANDIR2            
ANDIR1   MOVE.W      #$00,D5   * DN - EA Direction
        CMP.W       #$000,D3    
        BEQ         ANBYT        
        CMP.W       #$001,D3 
        BEQ         ANWRD        
        CMP.W       #$010,D3 
        BEQ         ANLNG          
ANDIR2   MOVE.W      #$11,D5   * EA - DN Direction
        CMP.W       #$100,D3    
        BEQ         ANBYT       
        CMP.W       #$101,D3    
        BEQ         ANWRD       
        CMP.W       #$110,D3
        BEQ         ANLNG         
ANBYT     MOVE.B      #14,D0     
        LEA         BYTE,A1           
        TRAP        #15 
        BRA         ANCONT       
ANWRD     MOVE.B      #14,D0      
        LEA         WORD,A1           
        TRAP        #15 
        BRA         ANCONT   
ANLNG     MOVE.B      #14,D0     
          LEA         LONG,A1          
          TRAP        #15   
   
ANCONT   
         MOVE.W        D5,(A4)+ 
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg

        JSR         AND_EA
        BRA         BACK
*---------------------------------------------------
OR
        MOVE.B      #14,D0  
        LEA         opcode_OR,A1    
        TRAP        #15 
        MOVE.W      D3,(A4)+    
       
        CMP.W       #$000,D3    
        BEQ         DIR1         
        CMP.W       #$001,D3 
        BEQ         DIR1         
        CMP.W       #$010,D3 
        BEQ         DIR1       
        CMP.W       #$100,D3    
        BEQ         DIR2        
        CMP.W       #$101,D3    
        BEQ         DIR2    
        CMP.W       #$110,D3
        BEQ         DIR2        
DIR1   MOVE.W      #$00,D5   * DN - EA Direction
        CMP.W       #$000,D3    
        BEQ         OBYT        
        CMP.W       #$001,D3 
        BEQ         OWRD        
        CMP.W       #$010,D3 
        BEQ         OLNG          
DIR2   MOVE.W      #$11,D5   * EA - DN Direction
        CMP.W       #$100,D3    
        BEQ         OBYT       
        CMP.W       #$101,D3    
        BEQ         OWRD       
        CMP.W       #$110,D3
        BEQ         OLNG         
OBYT     MOVE.B      #14,D0     
        LEA         BYTE,A1           
        TRAP        #15 
        BRA         OCONT       
OWRD     MOVE.B      #14,D0      
        LEA         WORD,A1           
        TRAP        #15 
        BRA         OCONT   
OLNG     MOVE.B      #14,D0     
          LEA         LONG,A1          
          TRAP        #15   


OCONT   
         MOVE.W        D5,(A4)+     
        MOVE.W      D3,(A4)+    *Opmode
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg
        
        BRA         BACK
*---------------------------------------------------
NOT
        MOVE.B      #14,D0  
        LEA         opcode_NOT,A1       
        TRAP        #15 
        
        MOVE.B      #2,D4   
        CLR.L       D3  
        JSR         LOOP    
        CMP.B       #$00,D3 
        BEQ         NBYT    
        CMP.B       #$01,D3 
        BEQ         NWRD    
        
        MOVE.B      #14,D0  
        LEA         LONG,A1 
        TRAP        #15 
        BRA         NCONT   
NBYT   
         MOVE.B      #14,D0  
         LEA         BYTE,A1     
         TRAP        #15 
         BRA         NCONT  
NWRD    
        MOVE.B      #14,D0  
        LEA         WORD,A1     
        TRAP        #15 
NCONT  
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA mode
        
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * EA reg
        
        BRA         BACK
*---------------------------------------------------
LSL
        MOVE.B      #14,D0  
        LEA         opcode_LSL,A1       
        TRAP        #15
        
        CMP.B       #$00,D6 
        BEQ         LBYT    
        CMP.B       #$10,D6     
        BEQ         LLNG    
        BRA         LWRD         

*---------------------------------------------------
LSR
        MOVE.B      #14,D0  
        LEA         opcode_LSR,A1       
        TRAP        #15
        
        CMP.B       #$00,D6 
        BEQ         LBYT    
        CMP.B       #$10,D6     
        BEQ         LLNG    
        BRA         LWRD 
        
*---------------------------------------------------
ASR
        MOVE.B      #14,D0  
        LEA         opcode_ASR,A1     
        TRAP        #15
        
        CMP.B       #$00,D6 
        BEQ         LBYT    
        CMP.B       #$10,D6     
        BEQ         LLNG    
        BRA         LWRD 
        
*---------------------------------------------------
ASL
        MOVE.B      #14,D0  
        LEA         opcode_ASL,A1    
        TRAP        #15
        
        CMP.B       #$00,D6 
        BEQ         LBYT    
        CMP.B       #$10,D6     
        BEQ         LLNG    
        BRA         LWRD 
        
*----------------------------------------------------------
* sizes for LSL/R AND ASL/R
LLNG    
         MOVE.B      #14,D0  
        LEA         LONG,A1 
        TRAP        #15 
        BRA         LCONT   
LBYT
        MOVE.B      #14,D0  
        LEA         BYTE,A1 
        TRAP        #15 
        BRA         LCONT  
LWRD
        MOVE.B      #14,D0  
        LEA         WORD,A1 
        TRAP        #15 
LCONT
        MOVE.W      #3,D4
        CLR.L       D3  
        JSR         LOOP
        MOVE.W      D3,(A4)+  * register
        
        BRA         BACK
        
*---------------------------------------------------
BGT
        MOVE.B      #14,D0  
        LEA         opcode_BGT,A1     
        TRAP        #15
        
        MOVE.B      #8,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.L      D3,(A4)+    *displacement
        
        BRA         BSIZE   
*---------------------------------------------------
BLE
        MOVE.B      #14,D0  
        LEA         opcode_BLE,A1     
        TRAP        #15
        
        MOVE.B      #8,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.L      D3,(A4)+    *displacement
        
        BRA         BSIZE   
*---------------------------------------------------
BEQ
        MOVE.B      #14,D0  
        LEA         opcode_BEQ,A1    
        TRAP        #15
        
        MOVE.B      #8,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.L      D3,(A4)+    *displacement
        
        BRA         BSIZE   
*---------------------------------------------------
JSR
        MOVE.B      #14,D0  
        LEA         opcode_JSR,A1   
        TRAP        #15
        
        ASL.W       #8,D2           
        ASL.W       #2,D2   * gets rid of jsr bits
        CLR         D4  
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * this should be the mode
        
        CLR         D4  
        CLR.L       D3  
        MOVE.W      #3,D4
        JSR         LOOP
        MOVE.W      D3,(A4)+  * this should be the register
        
        BRA         BACK
*---------------------------------------------------
RTS
        MOVE.B      #14,D0  
        LEA         opcode_RTS,A1   
        TRAP        #15 
        
        BRA         BACK
*---------------------------------------------------
BRA
        MOVE.B      #14,D0  
        LEA         opcode_BRA,A1     
        TRAP        #15
        
        MOVE.B      #8,D4   
        CLR.L       D3  
        JSR         LOOP    
        MOVE.L      D3,(A4)+    *displacement
              
*-----------------------------------------------------------------
* size for Bcc and BRA
BSIZE           
         CMP.L       #$00000000,D3   
        BEQ         BWORD     
        CMP.L       #$11111111,D3   
        BEQ         BLONG
        MOVE.B      #14,D0  
        LEA         BYTE,A1 
        TRAP        #15 
        BRA         BCONT   
BWORD   
        MOVE.B      #14,D0  
        LEA         WORD,A1     
        TRAP        #15 
        BRA         BCONT  
BLONG   
        MOVE.B      #14,D0  
        LEA         LONG,A1     
        TRAP        #15 
        BRA         BCONT  
BCONT   
        BRA         BACK


*---------------------- LOOP FOR GETTING BITS-------------
LOOP    
        ASL.W       #1,D2   *gets first bit
        BCS         ONE     * check if 1
        ADD.B       #$0,D3  * add 0
        SUB.B       #1,D4   * check if end loop
        BNE         SHIFT
        RTS
ONE     ADD.B       #$1,D3
        SUB.B       #1,D4   * check if end loop
        BNE         SHIFT 
        RTS
SHIFT   ASL.L       #4,D3           
        BRA         LOOP   
*--------------------- END OF LOOP -----------------------  
    INCLUDE 'EA.x68'






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
