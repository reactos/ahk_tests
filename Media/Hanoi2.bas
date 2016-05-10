#include "windows.bi"
#include "fbgfx.bi"
'#include "MyTDT\Sync.bas"

SetPriorityClass(GetCurrentProcess(),HIGH_PRIORITY_CLASS)

type PIE_STRUCT
  MAX as integer
  CIL(8) as byte
  NUM as byte
end type

declare sub ShowPies(NOHANOI as integer=0)
declare sub MoveAC(A as PIE_STRUCT ptr,B as PIE_STRUCT ptr)
declare sub TranslateXPIE(PIE as integer,PX as integer,PY as integer)
declare function Shade(COR as uinteger,PERCENT as integer) as uinteger
declare sub Hanoi(N as integer, A as PIE_STRUCT ptr, B as PIE_STRUCT ptr, C as PIE_STRUCT ptr)
declare sub Hanoi2(N as integer, A as PIE_STRUCT ptr, B as PIE_STRUCT ptr, C as PIE_STRUCT ptr)


using fb
const PI = 3.14592/180
const BGTWO = rgba(26,42,74,255)
const BGCOR = rgba(200,0,200,255)

dim shared as PIE_STRUCT XPIE(2)
dim shared as any ptr BAK(9),PIC(9)
dim shared as integer COR(9),OPX(9),OPY(9)
dim shared as integer TOHALT,DOANIM,SPD=2048
dim as double BT
dim as integer R,G,B,PX,PY,OX,OY
dim as any ptr SCRPTR
dim as uinteger COUNT,PT
dim as string TECLA

' ****************************** HANOI TITLE XDDDDDD ****************************
dim as byte DIFF(1069),ACT(1069)
dim as integer TITLE(1069) = {-1,63,22,63,32,61,46,60,52,60,66,60,89,60,101,61,106,63,115,64, _
120,-1,128,32,127,43,127,63,127,84,127,101,127,115,127,129,127,143,131,155,131,159,130,160, _
-1,127,82,123,83,114,83,105,83,98,83,92,83,86,83,80,83,75,83,71,83,70,83,66,83,64,83,56,84, _
-1,195,34,193,34,188,45,184,54,178,71,176,88,170,107,168,114,167,123,164,128,163,136, _
161,140,-1,193,44,196,45,199,51,205,60,209,69,212,78,214,85,217,94,220,107,221,111,226, _
115,230,119,-1,219,90,208,90,196,90,179,93,175,93,168,93,164,93,-1,262,134,263,112,264, _
91,265,74,264,61,264,57,265,53,266,51,267,48,268,44,269,41,269,40,271,45,279,68,286,85, _
290,97,295,113,299,123,299,124,299,125,300,117,301,93,302,66,303,54,-1,345,37,356,41,365, _
46,373,58,375,71,375,84,375,101,368,119,361,130,354,133,346,135,338,130,326,105,320,92, _
317,75,321,62,323,55,331,45,334,37,342,34,347,34,-1,403,42,407,42,417,42,431,42,439,42, _
457,42,464,42,-1,433,44,434,48,435,62,435,77,435,92,436,98,436,103,436,107,436,121,436, _
122,-1,397,135,405,135,423,135,434,135,451,135,461,135,470,135,467,135,-1,439,122,439,123, _
439,128,440,128,440,130,440,131,-1,437,121,438,122,442,130,442,132,-2,-12517568,-1,444, _
151,444,152,444,156,444,160,444,164,444,168,443,169,443,170,444,167,444,162,444,158,444, _
154,444,152,444,149,444,148,446,148,450,148,452,148,453,149,454,150,454,152,454,155,450, _
158,448,158,446,159,445,159,442,159,441,159,442,159,445,159,448,160,449,161,451,161,452, _
161,452,163,452,165,450,166,448,168,447,169,446,170,444,170,443,170,-1,461,149,462,150, _
463,153,463,154,464,155,465,158,465,159,465,160,466,160,467,159,468,155,468,153,469,150, _
470,149,-1,465,155,465,158,465,159,466,160,466,163,466,164,467,164,467,166,468,168,468, _
169,468,171,468,172,-1,478,154,479,154,480,154,480,156,480,157,481,157,482,157,481,158, _
480,159,479,159,477,160,476,160,477,158,478,157,478,156,478,155,479,154,-1,478,167,479, _
167,481,168,481,170,480,171,479,171,478,171,476,170,476,168,476,166,478,166,-1,492,175, _
493,173,496,168,499,161,499,155,499,150,499,145,500,141,500,139,500,138,501,138,503,138, _
504,142,504,148,506,153,508,157,509,158,510,161,511,163,515,159,517,153,519,148,520,145, _
521,143,521,141,522,139,522,141,522,147,522,151,522,154,523,157,524,158,525,158,-1,522, _
155,523,158,524,158,524,162,524,165,525,166,526,168,526,170,527,170,527,171,527,175,528, _
177,-1,532,144,533,145,535,148,536,149,537,152,537,154,538,155,539,155,539,156,541,157, _
541,158,542,159,543,160,544,160,548,155,550,151,550,149,551,147,552,147,552,146,553,144, _
-1,545,160,545,162,545,164,545,167,545,168,545,169,546,170,546,173,546,175,-1,572,145, _
570,145,569,145,566,146,564,147,561,148,559,149,558,150,558,151,559,153,562,155,563,156, _ 
566,157,568,157,569,158,570,160,571,162,571,163,571,164,571,166,570,166,569,166,567,166, _
566,167,562,170,-1,587,145,590,145,592,147,594,148,595,151,597,155,598,163,600,164,600, _
167,600,170,598,171,595,171,594,171,589,172,588,171,588,165,586,161,583,155,583,152,583, _
149,583,148,585,147,585,146,586,146,595,147,-1,609,146,609,150,609,153,609,159,609,163, _ 
609,166,609,168,610,170,610,172,610,176,-1,607,149,609,149,612,149,613,149,614,149,615, _
149,616,149,-1,608,162,609,162,612,162,613,162,614,162,-1,625,152,627,152,631,152,633,152, _
634,152,638,152,639,152,641,152,643,152,-1,634,154,635,154,635,155,635,157,635,161,635,163, _
635,164,635,165,635,167,635,168,635,171,635,172,635,173,-1,538,39,539,39,542,39,545,39,546, _
40,547,42,549,48,549,52,548,56,546,56,539,59,535,55,535,51,533,50,533,47,534,43,535,40,537, _
39,537,38,540,37,541,37,542,37,543,37,545,37,546,37,-1,587,35,589,37,593,38,596,41,597,46, _
598,48,598,53,598,56,596,58,592,60,591,61,589,61,584,59,582,57,579,55,577,53,577,50,577,48, _
577,44,578,41,580,39,582,38,583,36,584,36,587,34,589,34,590,34,591,34,592,34,592,35,593,35, _
-1,566,73,565,74,563,76,561,80,558,84,557,85,-1,567,75,568,75,568,77,569,78,571,81,571,84, _
572,85,573,86,573,87,574,87,575,87,-1,513,72,514,80,515,82,516,84,517,90,518,93,520,96,522, _
99,524,101,530,104,536,109,542,110,546,112,551,113,558,114,564,114,570,114,575,114,581,110,_ 
584,110,586,108,593,103,599,99,601,96,602,94,603,92,605,90,608,87,610,85,611,83,612,81,614, _
79,614,78 }

' **** Screen,Title,Colors and buffers ****
screencontrol SET_DRIVER_NAME,"GDI"
screenres 700,400,32,,fb.gfx_high_priority
WindowTitle "Hanoi2 by Mysoft"
for COUNT = 1 to 9
  read R,G,B
  COR(COUNT)= rgba(R,G,B,255)
  PIC(COUNT) = ImageCreate(203,35)
  BAK(COUNT) = ImageCreate(203,35)
next COUNT

' ************** Drawing and Buffering Pies ****************
screenlock
for COUNT = 9 to 1 step -1
  line(320-100,200-18)-(320+100,200+16),rgba(255,0,255,255),bf
  ' ***** bottom *****
  for PY = 208 to 208-16 step -1
    circle(320,PY),(COUNT+1)*10,BGCOR,,,.1,f
  next PY
  ' ***** top *****
  if COUNT = 9 then
    for PX = ((COUNT+1)*10) to 1 step -1
      circle(320,PY),PX,Shade(COR(COUNT),PX-3*(PX and 5)),,,.1,f  
    next PX
  else
    circle(320,PY),((COUNT+1)*10),COR(COUNT),,,.1,f
  end if
  ' ************* Shading the pie ***************
  for PY = 208-16 to 208+17
    for PX = 320-100 to 320+100
      if (point(PX,PY) and &HFFFFFF) = (BGCOR and &HFFFFFF) then
        PT = (sqr((((PX-320)*(100/((COUNT+1)*10)))^2)+(((PY-200)*4)^2)) and -1) 
        PT = 100-PT        
        pset(PX,PY),Shade(COR(COUNT),PT)
      end if
    next PX
  next PY
  ' *********** Buffering ******
  get(320-100,200-18)-(320+100,200+16),PIC(COUNT)  
next COUNT
line(0,0)-(699,399),rgb(16,32,64),bf
screenunlock 

' **************** Default Pies **************
XPIE(0).MAX = 8:XPIE(0).NUM = 0
XPIE(1).NUM = 1:XPIE(2).NUM = 2
for COUNT = 1 to 8
  XPIE(0).CIL(COUNT) = 9-COUNT
next COUNT

' **************** intro ************
ShowPies 1 
line(0,0)-(699,180),0,bf
line(0,0)-(699,175),rgb(64,128,255),bf
'line(5,5)-(694,184),BGTWO,bf

BT = timer
for G = 2 to 1069 step 4
  PT = rgb(255,64,64)
  screenlock
  for COUNT = 0 to G step 2
    if TITLE(COUNT) = -1 then
      OX = TITLE(COUNT+1)    
      OY = TITLE(COUNT+2)
      COUNT += 1
    elseif TITLE(COUNT) = -2 then
      PT = TITLE(COUNT+1)    
    else    
      PX = TITLE(COUNT)    
      PY = TITLE(COUNT+1)    
      line(OX,OY)-(PX,PY),PT    
      line(OX+1,OY)-(PX,PY+1),PT
      if COUNT < 320 then
        line(OX,OY+2)-(PX+1,PY+2),(PT shr 1)
        line(OX+1,OY+2)-(PX+1,PY+2),(PT shr 1)
      else
        line(OX,OY+2)-(PX+1,PY+2),rgb(16,32,64)
        line(OX+1,OY+2)-(PX+1,PY+2),rgb(16,32,64)
      end if
      OX = PX
      OY = PY    
    end if        
    pset(rnd*699,rnd*175),rgb(64,128,255)
  next COUNT  
  
  for B = 1 to 2
    SCRPTR = screenptr
    asm    
      mov ESI,[SCRPTR]
      mov ECX,700*185
      _NXPTX_:
      shr dword ptr [ESI],1
      and dword ptr [ESI],0x7F7F7F
      mov eax,[ESI+4]
      shr eax,2
      and eax,0x3F3F3F
      add dword ptr [ESI],eax
      mov eax,[ESI+2800]    
      shr eax,2
      and eax,0x3F3F3F
      add dword ptr [ESI],eax    
      add ESI,4
      dec ecx
      jnz _NXPTX_    
    end asm    
  next B
  'VSync(6)
  sleep 15,1
  screenunlock
  
  'while (timer-BT) < 1/30
  '  sleep 1
  'wend
  BT += 1/30
  if inkey$ <> "" goto _KEYPR_
  
next G

'sleep 2000
_KEYPR_:
Draw String (238,190),"Do you want animation (Y/N)?",rgb(63,127,255)

' ***** Macro Para Suavizar animação *******

#macro Adjust(WHERE)
if DIFF(WHERE) = ACT(WHERE) then
  DIFF(WHERE) = -3+rnd*6
end if
if ACT(WHERE) > DIFF(WHERE) then
  ACT(WHERE) -= 1
end if
if ACT(WHERE) < DIFF(WHERE) then
  ACT(WHERE) += 1
end if
#endmacro

' ******************** Animação do titulo *****************
BT = timer
do
  
  screenlock
  'line(5,5)-(694,184),BGTWO,bf
  PT = rgb(255,64,64)
  for COUNT = 0 to 1069 step 2
    if TITLE(COUNT) = -1 then
      Adjust(COUNT+1)
      OX = TITLE(COUNT+1)-ACT(COUNT+1)
      Adjust(COUNT+2)
      OY = TITLE(COUNT+2)-ACT(COUNT+2)
      COUNT += 1
    elseif TITLE(COUNT) = -2 then
      PT = TITLE(COUNT+1)    
    else
      Adjust(COUNT)
      PX = TITLE(COUNT)-ACT(COUNT)
      Adjust(COUNT+1)
      PY = TITLE(COUNT+1)-ACT(COUNT+1)
      line(OX,OY)-(PX,PY),PT    
      line(OX+1,OY)-(PX,PY+1),PT
      if COUNT < 320 then
        line(OX,OY+2)-(PX+1,PY+2),(PT shr 1)
        line(OX+1,OY+2)-(PX+1,PY+2),(PT shr 1)
      else
        line(OX,OY+2)-(PX+1,PY+2),rgb(16,32,64)
        line(OX+1,OY+2)-(PX+1,PY+2),rgb(16,32,64)
      end if
      OX = PX
      OY = PY    
    end if
  next COUNT  
  
  for COUNT = 0 to 512
    PX = rnd*699:PY = rnd*175
    'PT = point(PX,PY) 
    'if ((PT shr 8) and 255) < 128 and ((PT shr 16) and 255) < 128 then
    pset(rnd*699,rnd*175),rgb(64,128,255)
    'circle(PX,PY),1,rgb(64,128,255),,,,f  
    'end if
  next COUNT
  
  ' ************* Filter ***********
  SCRPTR = screenptr
  for COUNT = 1 to 3 '(timer and 3)+1
    asm
      mov ESI,[SCRPTR]
      mov ECX,700*185
      _NXPT_:
      shr dword ptr [ESI],1
      and dword ptr [ESI],0x7F7F7F
      mov eax,[ESI+4]
      shr eax,2
      and eax,0x3F3F3F
      add dword ptr [ESI],eax
      mov eax,[ESI+2800]    
      shr eax,2
      and eax,0x3F3F3F
      add dword ptr [ESI],eax    
      add ESI,4
      dec ecx
      jnz _NXPT_
    end asm    
  next COUNT  
  sleep 15,1
  'Vsync(6)
  screenunlock
  
  ' ****** sync e keys *****
  'while timer-BT < 1/30
  '  sleep 1
  'wend
  BT += 1/30
  TECLA = lcase$(inkey$)
  if TECLA = chr$(27) then end
loop until TECLA = "y" or TECLA = "n"
if TECLA = "y" then DOANIM = 1

' *********** "fadeout* ************
view screen(0,0)-(699,199)
BT = timer
for COUNT = 1 to 500 step 17
  circle(350,100),COUNT,rgb(16,32,64),,,.33,f
  while timer-BT < 1/60
    sleep 1
  wend
  'Vsync()
  BT += 1/60
next COUNT
view screen(0,0)-(699,399)
sleep 250

' **************** Starting Animation *****************
Draw String (98,5),"Press + to SPEEDUP the animation or - to SLOWDOWN the animation",rgb(63,127,255)
Hanoi(8,@XPIE(0),@XPIE(1),@XPIE(2))
ShowPies 1
Draw String (266,150),"Press any key to end.",rgb(63,127,255)
sleep

' *********** Color Data *************
data 252,200,200
data 150,0,150
data 252,252,252
data 252,150,0
data 0,252,0
data 252,252,0
data 252,0,0
data 0,0,252
data 120,80,30

' *********************************************************
' ****************** Create Shading Color *****************
' *********************************************************
function Shade(COR as uinteger,PERCENT as integer) as uinteger
  if PERCENT < 0 then PERCENT = 0
  if PERCENT > 100 then PERCENT = 100
  dim as integer R,G,B,A
  R = ((((COR shr 16) and 255)/100)*PERCENT)
  G = ((((COR shr 8) and 255)/100)*PERCENT)
  B = (((COR and 255)/100)*PERCENT)  
  A = (COR shr 24) and 255
  return rgba(R,G,B,A)
end function

' ************************************************************
' ****************** Show the Pies on screen *****************
' ************************************************************
sub ShowPies(NOHANOI as integer=0)
  dim as integer COUNT,PX,X,Y,C
  dim as string TECLA  
  
  if TOHALT<>0 and NOHANOI=0 then SPD=1
  
  screenlock
  line(0,190)-(699,399),rgb(16,32,64),bf
  
  ' ***** wood pie *****
  for PX = 25 to 25+225*2 step 225
    put(PX,200+9*18),PIC(9),trans  
  next PX
  ' **** other pies *****
  for PX = 0 to 2
    for COUNT = 1 to XPIE(PX).MAX        
      ' ** pos **
      X = 25+225*PX
      Y = 200+((9-COUNT)*18)
      C = XPIE(PX).CIL(COUNT)
      ' ** save back (anim) **
      'if DOANIM<>0 or NOHANOI<>0 then 
      get(X,Y)-(X+200,Y+34),BAK(C)
      OPX(C)=X:OPY(C)=Y        
      'end if
      ' ** put pie **
      put(X,Y),PIC(C),trans    
    next COUNT
  next PX
  
  screenunlock
  
  ' **** Sync and keys ****
  if NOHANOI = 0 then
    sleep SPD
    TECLA = inkey$
    if TECLA = "+" or TECLA = "=" and SPD > 1 then
      SPD shr= 1
    elseif TECLA = "-" or TECLA = "_" and SPD < 2048 then
      SPD shl= 1
    elseif TECLA = chr$(27) then 
      TOHALT = 1
    end if
  end if
  while inkey$ <> ""
    sleep 1,1
  wend  
  
end sub

' ****************************************************************
' **************************** HANOI 1 ***************************
' ****************************************************************
sub Hanoi(N as integer, A as PIE_STRUCT ptr, B as PIE_STRUCT ptr, C as PIE_STRUCT ptr)
  
  if N > 0 then    
    Hanoi(N-1,A,C,B)
    if DOANIM then
      MoveAC(A,C)
    else
      C->MAX += 1
      C->CIL(C->MAX) = A->CIL(A->MAX)    
      A->MAX -= 1
      ShowPies
    end if
    Hanoi(N-1,B,A,C)    
  end if  
end sub

' *********************************************************************
' **************************** HANOI 2 (=1) ***************************
' *********************************************************************
sub Hanoi2(N as integer, A as PIE_STRUCT ptr, B as PIE_STRUCT ptr, C as PIE_STRUCT ptr)
  
  if N > 0 then    
    Hanoi(N-1,A,C,B)    
    if DOANIM then
      MoveAC(A,C)
    else
      C->MAX += 1
      C->CIL(C->MAX) = A->CIL(A->MAX)    
      A->MAX -= 1
      ShowPies
    end if
    Hanoi(N-1,B,A,C)
  end if
  
end sub

sub MoveAC(A as PIE_STRUCT ptr,C as PIE_STRUCT ptr)
  dim as double XPIE,XX,YY,X,Y,CNT,PY
  dim as double BT,COY,COYY  
  dim as string TECLA
  X = 25+225*(A->NUM)
  Y = 200+((9-(A->MAX))*18)
  C->MAX += 1
  XPIE = A->CIL(A->MAX)
  C->CIL(C->MAX) = XPIE
  A->MAX -= 1
  XX = 25+225*(C->NUM)
  YY = 200+((9-(C->MAX))*18)
  COY = -acos((344-Y)/250)
  COYY = acos((344-YY)/250)
  BT = timer  
  for CNT = X to XX step ((XX-X)/45)*(2048/SPD)
    PY = 344-cos(COY+(((COYY-COY)/(XX-X))*(CNT-X)))*250
    TranslateXPIE(XPIE,CNT,PY)  
    'while (timer-BT) < 1/30
    '  sleep 1
    'wend        
    BT += 1/30
    TECLA = inkey$
    if TECLA = "+" or TECLA = "=" then
      if SPD > 1 then
        SPD shr= 1
      end if
    elseif TECLA = "-" or TECLA = "_" then
      if SPD < 2048 then
        SPD shl= 1
      end if
    elseif TECLA = chr$(27) then 
      DOANIM = 0:SPD = 1:exit for
    end if    
  next CNT
  TranslateXPIE(XPIE,XX,YY)
  
end sub

sub TranslateXPIE(XPIE as integer,PX as integer,PY as integer)
  screenlock
  put(OPX(XPIE),OPY(XPIE)),BAK(XPIE),pset
  get(PX,PY)-(PX+200,PY+34),BAK(XPIE)
  put(PX,PY),PIC(XPIE),trans
  OPX(XPIE)=PX:OPY(XPIE)=PY
  #ifdef Vsync
  Vsync(6)
  #else
  sleep 15,1
  #endif
  screenunlock
end sub
