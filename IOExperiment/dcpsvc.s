SVC19 CSECT
SVC19 AMODE 31
SVC19 RMODE ANY
*
* Input: 
* R1 points to DCB
* For SVC19:
* R0 needs to contain DCB address
* R1 needs to be 0
*
      LR 0,1
      LA 1,0
      SVC 19
      BCR B'1111',14
*
SVC20 CSECT
SVC20 AMODE 31
SVC20 RMODE ANY
*
* Input: 
* R1 points to DCB
* For SVC20:
* R0 needs to contain DCB address
* R1 needs to be 0
*
      LR 0,1
      LA 1,0
      SVC 20
      BCR B'1111',14
*
READ  CSECT
READ  AMODE 31
READ  RMODE ANY
*
* Input:
* R1 points to 4 fullwords
* 0 : buffer to write record to
* 4 : DCB for dataset 
* 8 : GET routine to call
* C : flag used by EOD (set to 1 when EOD triggered)
* If EOD triggered, control will transfer to 
* instruction after BASR 14,15
*
READP EDCPRLG USRDSAL=0,BASEREG=12
      L  0,0(,1)
      L  15,8(,1)
      L  2,12(,1)
      L  1,4(,1)
      BASR 14,15
*
READE EDCEPIL
*
EOD   CSECT
EOD   AMODE 31
EOD   RMODE ANY
* Input:
* R2 unchanged from before call to PUT (in READ)
* Store 1 into HOb to indicate EOD
* R15 contains address of location after BASR in READ
*
      MVI 0(2),128
      BCR B'1111',14
      END
