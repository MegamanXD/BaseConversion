*-----------------------------------------------------------
* Title      : Assignment 1 - Assembly Language Programming
* Written by : Nguyen Anh Minh, s3759797
* Date       : 20th Nov, 2018
* Description: Indescribable!!!
*-----------------------------------------------------------
    ORG    $1000
START:
       
* --------Main Menu--------
MainMenu    LEA     PromptMenu,A1               Display the Menu to the screen
            MOVE.B  #14,D0
            TRAP    #15
            
ChooseOption
            LEA     PromptOption,A1             Prompt user to choose options
            MOVE.B  #18,D0
            TRAP    #15
    
            BRA     base2                       Start checking the inputted option, first starting with Option 1 (Binary)
            
* --------Convert from Binary to other bases--------        
base2   CMP.B   #1,D1                           1 is the option for converting Binary => check if Binary Conversion is chosen
        BNE     base8                           If option 1 is not chosen, check if next option (Converting base 8) is chosen
ContinueConvertBinary
        BSR     NumberInputBinary               If option 1 is chosen, ask user for input
        
        BSR     Base2ToBase10                   After the user entered the Binary number, convert it to Decimal so Trap#15 task 15 can be used to convert it to other bases
        BSR     Base10ToBase8                   Use Trap#15 task 15 to convert from Decimal to Octal
        BSR     Base10ToBase16                  Use Trap#15 task 15 to convert from Decimal to Hexadecimal
        
        BSR     ContinueSameBaseOrNot           Ask user if they want to continue converting the same base or Go back to main menu
        BSR     ContinueConvertBinary           If the user wants to continue, loop back to convert another number

* --------Convert from Octal to other bases--------          
base8   CMP.B   #2,D1                           2 is the option for converting Octal => check if Octal Conversion is chosen
        BNE     base10                          If option 2 is not chosen, check if next option (Converting base 10) is chosen
ContinueConvertOctal
        BSR     NumberInputOctal                Converting Octal is basically the same process as converting Binary
        
        BSR     Base8ToBase10
        BSR     Base10ToBase2
        BSR     Base10ToBase16
        
        BSR     ContinueSameBaseOrNot
        BSR     ContinueConvertOctal

* --------Convert from Decimal to other bases--------
base10  CMP.B   #3,D1                           3 is the option for converting Decimal => check if Decimal Conversion is chosen
        BNE     base16                          If option 3 is not chosen, check if next option (Converting base 16) is chosen
ContinueConvertDecimal
        BSR     NumberInputDecimal              Converting Decimal is basically the same process as converting Binary 
        BSR     DisplayBase10                   Except we don't need to convert Decimal to itself, we can just display it to the screen
        
        BSR     Base10ToBase2
        BSR     Base10ToBase8
        BSR     Base10ToBase16
        
        BSR     ContinueSameBaseOrNot
        BSR     ContinueConvertDecimal

* --------Convert from Hexadecimal to other bases--------        
base16  CMP.B   #4,D1                           4 is the option for converting Hex => check if Hex Conversion is chosen
        BNE     ExitProgram                     If option 1 is not chosen, check if next option (Exit Program) is chosen
ContinueConvertHex
        BSR     NumberInputHex                  Converting Hexadecimal is basically the same process as converting Binary
        
        BSR     Base16ToBase10
        BSR     Base10ToBase2
        BSR     Base10ToBase8
        
        BSR     ContinueSameBaseOrNot
        BSR     ContinueConvertHex
        
ExitProgram
        CMP.B   #5,D1                           5 is the option for quitting the program
        BNE     InvalidInput                    If the option chosen is not 1, 2, 3, 4, or 5, then it is an invalid option
        BSR     SayBye                          If option 5 is chosen, activate the quitting process
        
InvalidInput    LEA     InvalidOption,A1        
                MOVE.B  #14,D0
                TRAP    #15                     Display the InvalidOption message to the screen
                
                BRA     ChooseOption            Ask the user again for a valid option
        
        
* --------User Input for Binary--------
NumberInputBinary
BinaryLoop  LEA     BinaryNumberOfDigits,A1     Prompt users for the number of digits they want to enter
            MOVE.B  #18,D0
            TRAP    #15
    
            CMP.B   #1,D1
            BLT     BinaryInvalid               If the number of digits is less than 1, it is invalid
    
            CMP.B   #32,D1                      For Binary, conversion is accurate up to 32 digits. If greater, it is invalid.
            BGT     BinaryInvalid

            MOVE.B  D1,D7                       Copy the inputted number of digits from D1 to a better location - D7 (D0 is for trap#15, D1 is for input, D2 is for base conversion)
            BRA     EnterBinaryDigits           Create a loop to ask the user for each digit
            
BinaryInvalid       LEA     BinaryDigitRangeError,A1    Display the BinaryDigitRangeError message to the screen if the number of digits inputted is invalid
                    MOVE.B  #14,D0
                    TRAP    #15
                    BRA     BinaryLoop                  Go back to BinaryLoop to ask the user again for the total number of digits

EnterBinaryDigits
    LEA     EnterEachDigit,A1               Prompt the user for each digit
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #5,D0                           Scan each digit as a Character
    TRAP    #15
    
    BSR     Skip1Line        
    BRA     CheckBinary0                    Check if the character is valid, starting with 0
    
CheckBinary0
            CMP.B   #$30,D1                 ASCII code for 0 => Check if the inputted character is 0
            BNE     CheckBinary1            If the inputted character is not 0, check if it is the next valid character
            
            CLR.L   D1                      If the character is 0, set D1 to 0
            BRA     ComputeBinary           Start converting the Binary number to Decimal number

CheckBinary1
            CMP.B   #$31,D1                 ASCII code for 1 => Check if the inputted character is 1
            BNE     ReEnterBinaryDigit      If the input is not 0 or 1 => Invalid => needs to re-enter
            
            CLR.L   D1
            MOVE.B  #1,D1                   If the character is 0, wipe D1 to 0, then set D1 to 1
            BRA     ComputeBinary           Start converting the Binary number to Decimal number

            
ReEnterBinaryDigit
                LEA     BinaryDigitError,A1 Display BinaryDigitError message to the screen if inputted digit is not valid (for binary, it's only 0 and 1)
                MOVE.B  #14,D0
                TRAP    #15
                BRA     EnterBinaryDigits   Go back to EnterBinaryDigits, ask the user again to input a valid digit
                
ComputeBinary
            ADD.L   D6,D6                   D6+D6 is the same as D6*2. I didn't use MULU because I want to use the full 32bits instead of just 16bits.
            ADD.L   D1,D6                   Convert to Decimal using the formular: D6 = D6*base + NextDigit. NextDigit is inputted by user and stored at D1.
            BRA     LoopBinaryOrNot         After calculation, check if the all the digits are entered.
            
LoopBinaryOrNot
            SUB.B   #1,D7                   After each successful input, number of digits remaining (D7) decreases by 1
            CMP.B   #0,D7                   
            BGT     EnterBinaryDigits       If there are >0 digits still remaining, continue to ask for digits
    RTS                                     Otherwise, stop asking for digits

* --------User input for Octal--------            
NumberInputOctal
OctalLoop   LEA     OctalNumberOfDigits,A1
            MOVE.B  #18,D0
            TRAP    #15                     Octal is exactly the same as Binary: ask for number of digits, check if number of digits is valid, ask for each digits, check for validity of each digit, convert everything to Decimal
    
            CMP.B   #1,D1                   The only differences are the messages displayed, Octal works for less digits (10 instead of 32), and Octal has more valid digits to check for (0-7 instead of 0-1)
            BLT     OctalInvalid
    
            CMP.B   #10,D1                  Octal can only convert accurately up to 10 digits. If greater, it is invalid.
            BGT     OctalInvalid

            MOVE.B  D1,D7
            BRA     EnterOctalDigits
            
OctalInvalid
            LEA     OctalDigitRangeError,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     OctalLoop   

EnterOctalDigits
    LEA     EnterEachDigit,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #5,D0
    TRAP    #15
    
    BSR     Skip1Line    
    BRA     CheckOct0
   
CheckOct0
            CMP.B   #$30,D1               ASCII code for 0
            BNE     CheckOct1
            CLR.L   D1
            BRA     ComputeOctal

CheckOct1
            CMP.B   #$31,D1               ASCII code for 1
            BNE     CheckOct2
            CLR.L   D1
            MOVE.B  #1,D1
            BRA     ComputeOctal

CheckOct2
            CMP.B   #$32,D1               ASCII code for 2
            BNE     CheckOct3
            CLR.L   D1
            MOVE.B  #2,D1
            BRA     ComputeOctal

CheckOct3
            CMP.B   #$33,D1               ASCII code for 3
            BNE     CheckOct4
            CLR.L   D1
            MOVE.B  #3,D1
            BRA     ComputeOctal

CheckOct4
            CMP.B   #$34,D1               ASCII code for 4
            BNE     CheckOct5
            CLR.L   D1
            MOVE.B  #4,D1
            BRA     ComputeOctal

CheckOct5
            CMP.B   #$35,D1               ASCII code for 5
            BNE     CheckOct6
            CLR.L   D1
            MOVE.B  #5,D1
            BRA     ComputeOctal

CheckOct6
            CMP.B   #$36,D1               ASCII code for 6
            BNE     CheckOct7
            CLR.L   D1
            MOVE.B  #6,D1
            BRA     ComputeOctal
            
CheckOct7
            CMP.B   #$37,D1               ASCII code for 7
            BNE     ReEnterOctalDigit
            CLR.L   D1
            MOVE.B  #7,D1
            BRA     ComputeOctal
            
ReEnterOctalDigit
                LEA     OctalDigitError,A1
                MOVE.B  #14,D0
                TRAP    #15
                BRA     EnterOctalDigits

ComputeOctal
            ADD.L   D6,D6               This is D6 * 2
            ADD.L   D6,D6               This is D6 * 4
            ADD.L   D6,D6               This is D6 * 8

            ADD.L   D1,D6               This is D6 * 8 + D1
            BRA     LoopOctalOrNot
                
LoopOctalOrNot
            SUB.B   #1,D7
            CMP.B   #0,D7
            BGT     EnterOctalDigits
            RTS

* --------User input for Decimal--------
NumberInputDecimal
DecimalLoop LEA     DecimalNumberOfDigits,A1
            MOVE.B  #18,D0
            TRAP    #15                         Decimal is exactly the same as Binary: ask for number of digits, check if the number of digits is valid, ask for each digits, check for validity of each digits, read the digits and convert them back to Decimal
    
            CMP.B   #1,D1                       The only differences are the messages displayed, Decimal works for less digits (9 instead of 32), and Decimal has more valid digits to check for (0-9 instead of 0-1)
            BLT     DecimalInvalid
    
            CMP.B   #9,D1                       Decimal can only convert accurately up to 9 digits. If greater, it is invalid.
            BGT     DecimalInvalid

            MOVE.B  D1,D7
            BRA     EnterDecimalDigits
            
DecimalInvalid
            LEA     DecimalDigitRangeError,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     DecimalLoop   

EnterDecimalDigits
    LEA     EnterEachDigit,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #5,D0
    TRAP    #15
    
    BSR     Skip1Line  
    BRA     CheckDec0
    
CheckDec0
            CMP.B   #$30,D1               ASCII code for 0
            BNE     CheckDec1
            CLR.L   D1
            BRA     ComputeDecimal

CheckDec1
            CMP.B   #$31,D1               ASCII code for 1
            BNE     CheckDec2
            CLR.L   D1
            MOVE.B  #1,D1
            BRA     ComputeDecimal

CheckDec2
            CMP.B   #$32,D1               ASCII code for 2
            BNE     CheckDec3
            CLR.L   D1
            MOVE.B  #2,D1
            BRA     ComputeDecimal

CheckDec3
            CMP.B   #$33,D1               ASCII code for 3
            BNE     CheckDec4
            CLR.L   D1
            MOVE.B  #3,D1
            BRA     ComputeDecimal

CheckDec4
            CMP.B   #$34,D1               ASCII code for 4
            BNE     CheckDec5
            CLR.L   D1
            MOVE.B  #4,D1
            BRA     ComputeDecimal

CheckDec5
            CMP.B   #$35,D1               ASCII code for 5
            BNE     CheckDec6
            CLR.L   D1
            MOVE.B  #5,D1
            BRA     ComputeDecimal

CheckDec6
            CMP.B   #$36,D1               ASCII code for 6
            BNE     CheckDec7
            CLR.L   D1
            MOVE.B  #6,D1
            BRA     ComputeDecimal
            
CheckDec7
            CMP.B   #$37,D1               ASCII code for 7
            BNE     CheckDec8
            CLR.L   D1
            MOVE.B  #7,D1
            BRA     ComputeDecimal

CheckDec8
            CMP.B   #$38,D1               ASCII code for 8
            BNE     CheckDec9
            CLR.L   D1
            MOVE.B  #8,D1
            BRA     ComputeDecimal

CheckDec9
            CMP.B   #$39,D1               ASCII code for 9
            BNE     ReEnterDecimalDigit
            CLR.L   D1
            MOVE.B  #9,D1
            BRA     ComputeDecimal
            
ReEnterDecimalDigit
                LEA     DecimalDigitError,A1
                MOVE.B  #14,D0
                TRAP    #15
                BRA     EnterDecimalDigits
                
ComputeDecimal
            ADD.L   D6,D6                   This is D6 * 2
            MOVE.L  D6,D5                   This is D5 = D6 * 2
            
            ADD.L   D6,D6                   This is D6 * 4
            ADD.L   D6,D6                   This is D6 * 8
            ADD.L   D5,D6                   This is D6 * 8 + D6 * 2 = D6 * 10
            
            ADD.B   D1,D6                   This is D6 * 10 + D1
            BRA     LoopDecimalOrNot


LoopDecimalOrNot
            SUB.B   #1,D7
            CMP.B   #0,D7
            BGT     EnterDecimalDigits
            RTS

* --------User input for Hexadecimal--------            
NumberInputHex
HexLoop     LEA     HexNumberOfDigits,a1
            MOVE.B  #18,D0
            TRAP    #15                     Hexadecimal is exactly the same as Binary: ask for number of digits, check if number of digits is valid, ask for each digits, check for validity of each digit, convert everything to Decimal
    
            CMP.B   #1,D1                   The only differences are the messages displayed, Hex works for less digits (8 instead of 32), and Hex has more valid digits to check for (0-F instead of 0-1)
            BLT     HexInvalid              Just to be sure, both capitalized characters (A-F) and normal characters (a-f) are supported in this program
    
            CMP.B   #8,D1                   Hexadecimal can only convert accurately up to 8 digits. If greater, it is invalid.
            BGT     HexInvalid

            MOVE.B  D1,D7
            BRA     EnterHexDigits
            
HexInvalid  LEA     HexDigitRangeError,A1
            MOVE.B  #14,D0
            TRAP    #15
            BRA     HexLoop   

EnterHexDigits
    LEA     EnterEachDigit,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #5,D0
    TRAP    #15
    
    BSR     Skip1Line
    BRA     CheckHex0
    
CheckHex0
            CMP.B   #$30,D1               ASCII code for 0
            BNE     CheckHex1
            CLR.L   D1
            BRA     ComputeHex

CheckHex1   CMP.B   #$31,D1               ASCII code for 1
            BNE     CheckHex2
            CLR.L   D1
            MOVE.B  #1,D1
            BRA     ComputeHex

CheckHex2   CMP.B   #$32,D1               ASCII code for 2
            BNE     CheckHex3
            CLR.L   D1
            MOVE.B  #2,D1
            BRA     ComputeHex

CheckHex3   CMP.B   #$33,D1               ASCII code for 3
            BNE     CheckHex4
            CLR.L   D1
            MOVE.B  #3,D1
            BRA     ComputeHex

CheckHex4   CMP.B   #$34,D1               ASCII code for 4
            BNE     CheckHex5
            CLR.L   D1
            MOVE.B  #4,D1
            BRA     ComputeHex

CheckHex5   CMP.B   #$35,D1               ASCII code for 5
            BNE     CheckHex6
            CLR.L   D1
            MOVE.B  #5,D1
            BRA     ComputeHex

CheckHex6   CMP.B   #$36,D1               ASCII code for 6
            BNE     CheckHex7
            CLR.L   D1
            MOVE.B  #6,D1
            BRA     ComputeHex

CheckHex7   CMP.B   #$37,D1               ASCII code for 7
            BNE     CheckHex8
            CLR.L   D1
            MOVE.B  #7,D1
            BRA     ComputeHex

CheckHex8   CMP.B   #$38,D1               ASCII code for 8
            BNE     CheckHex9
            CLR.L   D1
            MOVE.B  #8,D1
            BRA     ComputeHex

CheckHex9   CMP.B   #$39,D1               ASCII code for 9
            BNE     CheckA
            CLR.L   D1
            MOVE.B  #9,D1
            BRA     ComputeHex
                                       
CheckA      CMP.B   #$41,D1               ASCII code for A
            BNE     CheckFora
            CLR.L   D1
            MOVE.B  #10,D1
            BRA     ComputeHex
            
CheckFora   CMP.B   #$61,D1               ASCII code for a
            BNE     CheckB
            CLR.L   D1
            MOVE.B  #10,D1
            BRA     ComputeHex
            
CheckB      CMP.B   #$42,D1               ASCII code for B
            BNE     CheckForb
            CLR.L   D1
            MOVE.B  #11,D1
            BRA     ComputeHex
            
CheckForb   CMP.B   #$62,D1               ASCII code for b
            BNE     CheckC
            CLR.L   D1
            MOVE.B  #11,D1
            BRA     ComputeHex

CheckC      CMP.B   #$43,D1               ASCII code for C
            BNE     CheckForc
            CLR.L   D1
            MOVE.B  #12,D1
            BRA     ComputeHex
            
CheckForc   CMP.B   #$63,D1               ASCII code for c
            BNE     CheckD
            CLR.L   D1
            MOVE.B  #12,D1
            BRA     ComputeHex

CheckD      CMP.B   #$44,D1               ASCII code for D
            BNE     CheckFord
            CLR.L   D1
            MOVE.B  #13,D1
            BRA     ComputeHex
            
CheckFord   CMP.B   #$64,D1               ASCII code for d
            BNE     CheckE
            CLR.L   D1
            MOVE.B  #13,D1
            BRA     ComputeHex

CheckE      CMP.B   #$45,D1               ASCII code for E
            BNE     CheckFore
            CLR.L   D1
            MOVE.B  #14,D1
            BRA     ComputeHex

CheckFore   CMP.B   #$65,D1               ASCII code for e
            BNE     CheckF
            CLR.L   D1
            MOVE.B  #14,D1
            BRA     ComputeHex

CheckF      CMP.B   #$46,D1               ASCII code for F
            BNE     CheckForf
            CLR.L   D1
            MOVE.B  #15,D1
            BRA     ComputeHex

CheckForf   CMP.B   #$66,D1               ASCII code for f
            BNE     ReEnterHexDigit
            CLR.L   D1
            MOVE.B  #15,D1
            BRA     ComputeHex

ReEnterHexDigit LEA     HexDigitError,A1
                MOVE.B  #14,D0
                TRAP    #15
                BRA     EnterHexDigits

ComputeHex  ADD.L   D6,D6               This is D6 * 2
            ADD.L   D6,D6               This is D6 * 4
            ADD.L   D6,D6               This is D6 * 8
            ADD.L   D6,D6               This is D6 * 16
            
            ADD.B   D1,D6               This is D6 * 16 + D1            
            BRA     LoopHexOrNot
            
LoopHexOrNot
            SUB.B   #1,D7
            CMP.B   #0,D7
            BGT     EnterHexDigits
            RTS
            
* --------Line Break sub-routine--------                
Skip1Line
    LEA     LineBreak,A1                A sub-routine used to skip a line for neater display of messages
    MOVE.B  #14,D0
    TRAP    #15
    RTS

* --------Base Conversion sub-routines--------         
Base2ToBase10
    BSR     Skip1Line
    
    LEA     BinaryInputtedNumber,A1     Display the message "Your number (Binary) = " to the screen
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #2,D2                       D6 is the converted number in Decimal. Use Trap#15 task 15 to convert back to inputted base (2) and display it to the screen
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line                   After the first message is completed, skip a line to display the next message.
    
    LEA     ToBase10,A1                 Display the message "To Decimal     = " to the screen
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #10,D2                      Display the converted number in Decimal to the screen
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line                   After the message is completed, skip a line to display the next message.
    RTS
    
Base8ToBase10
    BSR     Skip1Line
    
    LEA     OctalInputtedNumber,A1      Base8ToBase10 is practically the same as Base2ToBase10, except for the messages and the base (8 instead of 2)
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #8,D2                       Base 8 instead of base 2
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line
    
    LEA     ToBase10,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #10,D2
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line
    RTS
    
Base16ToBase10
    BSR     Skip1Line
    
    LEA     HexInputtedNumber,A1        Base16ToBase10 is practically the same as Base2ToBase10, except for the messages and the base (16 instead of 2)
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #16,D2                      Base 16 instead of Base 2
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line
    
    LEA     ToBase10,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #10,D2
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line
    RTS

DisplayBase10
    BSR     Skip1Line
    
    LEA     DecimalInputtedNumber,A1     DisplayBase10 is practically the same as Base2ToBase10, except for the messages and the base (10 instead of 2)
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #10,D2                       Base 10 instead of base 2
    MOVE.L  D6,D1
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line
    RTS

Base10ToBase2
    LEA     toBase2,A1                  Display the message "To Binary      = " to the screen
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #2,D2                       Convert the number to Binary and display it to the screen
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line                   Skip a line to display other messages
    RTS

Base10ToBase8
    LEA     toBase8,A1                  Display the message "To Octal       = " to the screen
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #8,D2                       Convert the number to Octal and display it to the screen
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line                   Skip a line to display other messages
    RTS

Base10ToBase16
    LEA     toBase16,A1                 Display the message "To Hexadecimal = " to the screen
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #16,D2                      Convert the number to Octal and display it to the screen
    MOVE.B  #15,D0
    TRAP    #15
    
    BSR     Skip1Line                   Skip a line to display other messages
    RTS

* --------Continue Conversion Or Not--------
ContinueSameBaseOrNot
            CLR.L   D5                  Reset Data Register 5 - used for storing D6 * 2
            CLR.L   D6                  Reset Data Register 6 - used for storing the converted number in Decimal
            CLR.L   D7                  Reset Data Register 7 - used for storing Number of Digits to be entered
            
YesNoLoop   LEA     PromptContinue,a1   Ask if the user wants to continue converting the same base
            MOVE.B  #14,D0
            TRAP    #15
    
            MOVE.B  #5,D0               Scan the answer as a character
            TRAP    #15
    
            CMP.B   #$79,D1             ASCII code for y => Check if the user answered Yes
            BEQ     NewLoop             If yes, create a new loop to convert another number

            CMP.B   #$59,D1             ASCII code for Y => Check if the user answered Yes
            BEQ     NewLoop             If yes, create a new loop to convert another number    
            BNE     ReturnToMenu        If neither y nor Y is inputted, check if the user wanted to return to menu
            
NewLoop     MOVE.W  #$FF00,D1           If the user answered yes, first, wipe the screen
            MOVE.B  #11,D0
            TRAP    #15
        
            LEA     PromptMenu,A1       Then, display the main menu again
            MOVE.B  #14,D0
            TRAP    #15

            RTS                         Finally, return back to the converting process
    
ReturnToMenu
            CMP.B   #$6E,d1                 ASCII code for n => Check if the user answered No
            BEQ     BackToMainMenu          If no, return back to the main menu
        
            CMP.B   #$4E,d1                 ASCII code for N => Check if the user answered No
            BNE     ReEnter                 If the user did not inputted y/Y or n/N, ask the user again to input a valid choice
            BSR     BackToMainMenu          Else, the user answered no, return back to the main menu

BackToMainMenu
            MOVE.W  #$FF00,D1               First, wipe the entire screen
            MOVE.B  #11,D0
            TRAP    #15
        
            BRA     MainMenu                Then finally, return to the Main Menu

ReEnter     LEA     YesNoError,A1           If the user inputted an invalid choice, display the YesNoError message
            MOVE.B  #14,D0
            TRAP    #15
      
            BRA     YesNoLoop               Ask the user again to input a valid Yes or No choice
        RTS

* --------Quit Program sub-routine--------
SayBye  MOVE.W  #$FF00,D1               Clear the screen
        MOVE.B  #11,D0
        TRAP    #15

        LEA     Exit,A1                 Load the Exit message, displaying student name and ID number
        MOVE.B  #14,D0
        TRAP    #15
        
        MOVE.B  #9,D0                   Terminate the program
        TRAP    #15
        
        RTS

* --------List of messages--------
cr EQU $d
lf EQU $a
LineBreak       DC.B cr,lf,0
SectionBreak    DC.B cr,lf,cr,lf,'   -------------------------------------------------------------------------',cr,lf,0
        
PromptMenu      DC.B 'Hi, professor Anna!',cr,lf
                DC.B 'I hope marking my work is an enjoyable process for you :)',cr,lf,cr,lf

                DC.B 'Please choose an option: ',cr,lf
                DC.B '1.    Convert a Binary number',cr,lf
                DC.B '2.    Convert an Octal number',cr,lf
                DC.B '3.    Convert a Decimal number',cr,lf
                DC.B '4.    Convert a Hexadecimal number',cr,lf
                DC.B '5.    Quit',cr,lf,cr,lf
                DC.B 'NOTE: When entering each individual digit, do not press Enter!',cr,lf
                DC.B cr,lf,'   -------------------------------------------------------------------------',cr,lf,0
                
PromptOption    DC.B 'Enter option: ',0
InvalidOption   DC.B 'Invalid! Please enter only 1, 2, 3, 4, or 5',cr,lf,cr,lf,0

BinaryNumberOfDigits    DC.B    cr,lf,'[Converting Binary] Enter number of digits (1-32): ',0
BinaryDigitRangeError   DC.B    'Invalid! The range is 1-32',cr,lf,0
BinaryDigitError        DC.B    cr,lf,'Invalid! Binary is strictly 0 and 1!',cr,lf,0
BinaryInputtedNumber    DC.B    'Your number (Binary) = ',0

OctalNumberOfDigits     DC.B    cr,lf,'[Converting Octal] Enter number of digits (1-10): ',0
OctalDigitRangeError    DC.B    'Invalid! The range is 1-10',cr,lf,0
OctalDigitError         DC.B    cr,lf,'Invalid! Octal is strictly 0-7!',cr,lf,0
OctalInputtedNumber     DC.B    'Your number (Octal) = ',0

DecimalNumberOfDigits   DC.B    cr,lf,'[Converting Decimal] Enter number of digits (1-9): ',0
DecimalDigitRangeError  DC.B    'Invalid! The range is 1-9',cr,lf,0
DecimalDigitError       DC.B    cr,lf,'Invalid! Decimal is strictly 0-9!',cr,lf,0
DecimalInputtedNumber   DC.B    'Your number (Decimal) = ',0

HexNumberOfDigits       DC.B    cr,lf,'[Converting Hexadecimal] Enter number of digits (1-8): ',0
HexDigitRangeError      DC.B    'Invalid! The range is 1-8',cr,lf,0
HexDigitError           DC.B    cr,lf,'Invalid! Hex is strictly 0-9 and A-F!',cr,lf,0
HexInputtedNumber       DC.B    'Your number (Hexadecimal) = ',0

EnterEachDigit          DC.B    'Enter your digit: ',0


toBase2     DC.B 'To Binary      = ',0
toBase8     DC.B 'To Octal       = ',0
toBase10    DC.B 'To Decimal     = ',0
toBase16    DC.B 'To Hexadecimal = ',0


PromptContinue  DC.B cr,lf,'Continue converting the same base? (y/n) ',cr,lf,0
Exit            DC.B 'Hope you enjoyed the program. See you!',cr,lf
                DC.B 'Nguyen Anh Minh, s3759797',cr,lf,0
                
YesNoError      DC.B cr,lf,'Invalid! Please enter y/Y or n/N only.',cr,lf,0
         
* --------Run the code--------
    END    START


























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
