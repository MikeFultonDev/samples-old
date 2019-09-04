SVC19 CSECT
SVC19 AMODE 31
SVC19 RMODE ANY
      DS 0F
      LR 0,1
      LA 1,0
      SVC 19
      BCR B'1111',14
*
SVC20 CSECT
SVC20 AMODE 31
SVC20 RMODE ANY
      DS 0F
      LR 0,1
      LA 1,0
      SVC 20
      BCR B'1111',14
*
READ  CSECT
READ  AMODE 31
READ  RMODE ANY
      DS 0F
      L  0,0(,1)
      L  15,8(,1)
      L  1,4(,1)
      BCR B'1111',15
      END
