  OMIT('***')
  * Animated Label v1.01
  * Created by: <Mike Duglas> mikeduglas@yandex.ru
  ***
  
  MEMBER

  INCLUDE('AnimLabel.inc'), ONCE

  MAP
    MODULE('WinAPI')
      al::SetWindowLong(HWND hWnd,LONG nIndex,LONG dwNewLong),LONG,PASCAL,PROC,NAME('SetWindowLongA')
      al::GetWindowLong(HWND hWnd,LONG nIndex),LONG,PASCAL,NAME('GetWindowLongA')
      al::CallWindowProc(LONG lpPrevWndFunc,HWND hWnd,UNSIGNED wMsg,UNSIGNED wParam,LONG lParam),LONG,PASCAL,NAME('CallWindowProcA')
      al::DefWindowProc(HWND hWnd, UNSIGNED nMsg, UNSIGNED wParam, LONG lParam),LONG,PASCAL,NAME('DefWindowProcA')
      al::GetObject(UNSIGNED hgdiobj, LONG cbBuffer, LONG lpvObject),LONG,RAW,PASCAL,NAME('GetObjectA'),PROC
      al::SendMessage(UNSIGNED hWnd, ULONG uMsg, LONG wParam, LONG lParam),LONG,RAW,PASCAL,NAME('SendMessageA'),PROC
      al::GetWindowRect(HWND hWnd,*_RECT_ lpRect),BOOL,RAW,PASCAL,PROC,NAME('GetWindowRect')
      al::GetLastError(),lONG,PASCAL,NAME('GetLastError')
      al::OutputDebugString(*CSTRING lpOutputString), PASCAL, RAW, NAME('OutputDebugStringA')
    END

    al::CallBackProc(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam), LONG, PASCAL, PRIVATE
    al::GetLogFont(HWND hwnd, *TLOGFONT lf), BOOL, PROC, PRIVATE
    !
    LOWORD(LONG pLongVal), SIGNED, PRIVATE
    HIWORD(LONG pLongVal), SIGNED, PRIVATE
  END

!region TDummyPrompt declarations
TDummyPrompt                  CLASS, TYPE
feq                             SIGNED, PRIVATE
Destruct                        PROCEDURE()
Init                            PROCEDURE(SIGNED pFeq, STRING pText)
FullWidth                       PROCEDURE(), UNSIGNED
SpaceWidth                      PROCEDURE(), UNSIGNED
                              END
!endregion

!region static functions
al::DebugInfo                 PROCEDURE(STRING s)
prefix                          STRING('[Animated Label] ')
cs                              CSTRING(LEN(s) + LEN(prefix) + 1)
  CODE
  cs = prefix & s
  al::OutputDebugString(cs)

al::GetLogFont                PROCEDURE(HWND hwnd, *TLOGFONT lf)
hf                              HFONT, AUTO
bret                            BOOL, AUTO
  CODE
  hf = al::SendMessage(hwnd, WM_GETFONT, 0, 0)
  bret = al::GetObject(hf, SIZE(TLOGFONT), ADDRESS(lf))
  IF NOT al::GetObject(hf, SIZE(TLOGFONT), ADDRESS(lf))
    al::DebugInfo('GetObject failed, error '& al::GetLastError())
  END

  RETURN bret

al::CallBackProc              PROCEDURE(HWND hWnd,ULONG wMsg,UNSIGNED wParam,LONG lParam)
lpcb                            LONG, AUTO
cb                              &ILblCallBack
  CODE
  IF wMsg <> WM_DESTROY AND wMsg <> WM_NCDESTROY
    lpcb = al::GetWindowLong(hWnd, GWL_USERDATA)
    IF lpcb
      cb &= (lpcb)
      IF NOT cb &= NULL
        !-- user control
        RETURN cb.WndProc(hWnd, wMsg, wParam, lParam)
      END
    END
  END
  
  RETURN al::DefWindowProc(hWnd, wMsg, wParam, lParam)
  
LOWORD                        PROCEDURE(LONG pLongVal)
  CODE
  RETURN BAND(pLongVal, 0FFFFh)

HIWORD                        PROCEDURE(LONG pLongVal)
  CODE
  RETURN BSHIFT(BAND(pLongVal, 0FFFF0000h), -16)
!endregion static functions

!region TWinPix
TWinPix.Construct             PROCEDURE()
  CODE
  SELF.bPropPixels = 0{PROP:Pixels}
  0{PROP:Pixels} = TRUE
  
TWinPix.Destruct              PROCEDURE()
  CODE
  0{PROP:Pixels} = SELF.bPropPixels
!endregion

!region TDummyPrompt
TDummyPrompt.Destruct         PROCEDURE()
  CODE
  IF SELF.feq <> 0
    DESTROY(SELF.feq)
  END

TDummyPrompt.Init             PROCEDURE(SIGNED pFeq, STRING pText)
  CODE
  ASSERT(pFeq <> 0)
  SELF.feq = CREATE(0, pFeq{PROP:Type})
  SELF.feq{PROP:Text} = pText
  SETFONT(SELF.feq, pFeq{PROP:FontName}, pFeq{PROP:FontSize}, pFeq{PROP:FontColor}, pFeq{PROP:FontStyle}, pFeq{PROP:FontCharset})

TDummyPrompt.FullWidth        PROCEDURE()
winpix                          TWinPix
  CODE
  ASSERT(SELF.feq <> 0)
  RETURN SELF.feq{PROP:Width}
  
TDummyPrompt.SpaceWidth       PROCEDURE()
winpix                          TWinPix
char                            STRING(1), AUTO
nospaceString                   STRING(255), AUTO
nospaceCtrl                     TDummyPrompt
nospaceWidth                    SIGNED, AUTO
spaceNum                        UNSIGNED, AUTO
cIndex                          LONG, AUTO
  CODE
  ASSERT(SELF.feq <> 0)
  
  ! Узнать размер пробела:
  !   (длина_строки - длина_строки_без_пробелов) / количество_пробелов
  
  nospaceString = ''
  spaceNum = 0
  LOOP cIndex = 1 TO LEN(SELF.feq{PROP:Text})
    char = SUB(SELF.feq{PROP:Text}, cIndex, 1)
    IF char <> ' '
      nospaceString = CLIP(nospaceString) & char
    ELSE
      spaceNum += 1
    END
  END
  
  IF spaceNum = 0
    RETURN 0
  END
  
  
  nospaceCtrl.Init(SELF.feq, nospaceString)
  RETURN (SELF.feq{PROP:Width} - nospaceCtrl.FullWidth()) / spaceNum
!endregion
  
!region TAnimationTimer
TAnimationTimer.BindCtrl      PROCEDURE(ITmrCallBack pCtrl)
  CODE
  SELF.ctrl &= pCtrl

TAnimationTimer.GetTickCounter    PROCEDURE()
  CODE
  RETURN SELF.tickCounter
  
TAnimationTimer.ResetTickCounter  PROCEDURE()
  CODE
  SELF.tickCounter = 0
  
TAnimationTimer.Tick          PROCEDURE()
  CODE
  SELF.tickCounter += 1
  
  IF NOT SELF.ctrl &= NULL
    SELF.ctrl.OnTick()
  END
!endregion

!region TLabelBase
TLabelBase.Init               PROCEDURE(SIGNED pFeq)
winpix                          TWinPix
  CODE
  IF SELF.Feq <> 0
    !-- already initialized
    al::DebugInfo('Control '& pFeq &' already initialized')
    RETURN
  END

  ASSERT(pFeq <> 0)
  IF pFeq = 0
    al::DebugInfo('Invalid control feq')
    RETURN
  END
  
  SELF.feq = pFeq
  SELF.W &= TARGET
  SELF.hwnd = pFeq{PROP:Handle}
  SELF.wndProcAddr = pFeq{PROP:WNDProc}

  al::SetWindowLong(SELF.hwnd, GWL_USERDATA, ADDRESS(SELF.ILblCallBack))
  pFeq{PROP:WNDProc} = ADDRESS(al::CallBackProc)

TLabelBase.ILblCallBack.WndProc   PROCEDURE(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam)
szText                              &CSTRING, AUTO
hf                                  HFONT, AUTO
lf                                  LIKE(TLOGFONT), AUTO
lpwp                                &TWINDOWPOS, AUTO
  CODE
  CASE wMsg
  OF WM_SETTEXT
    szText &= (lParam)
    SELF.SetText(szText)
  OF WM_SETFONT
    hf = wParam
    IF al::GetObject(hf, SIZE(TLOGFONT), ADDRESS(lf))
      SELF.SetFont(lf)
    ELSE
      al::DebugInfo('GetObject failed, error '& al::GetLastError())
    END
  OF WM_WINDOWPOSCHANGED
    lpwp &= (lParam)
    SELF.SetPosition(lpwp)
    
!  OF 0138h  !WM_CTLCOLORSTATIC
    !-- при изменении PROP:FontColor приходит событие WM_SETFONT
!    al::DebugInfo('WM_CTLCOLORSTATIC')
    
  ELSE
!    al::DebugInfo('wMsg '& wMsg)
  END
  
  RETURN SELF.WndProc(hWnd, wMsg, wParam, lParam)

TLabelBase.WndProc            PROCEDURE(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam)
  CODE
  RETURN al::CallWindowProc(SELF.wndProcAddr, hWnd, wMsg, wParam, lParam)
  
TLabelBase.SetText            PROCEDURE(STRING pText)
  CODE

TLabelBase.SetPosition        PROCEDURE(TWINDOWPOS wp)
  CODE

TLabelBase.SetFont            PROCEDURE(TLOGFONT lf)
  CODE

!endregion TLabelBase

!region TAnimatedLabel
TAnimatedLabel.Construct      PROCEDURE()
  CODE
  SELF.tmr &= NEW TAnimationTimer
  SELF.tmr.BindCtrl(SELF.ITmrCallBack)

TAnimatedLabel.Destruct       PROCEDURE()
  CODE
  IF NOT SELF.tmr &= NULL
    SELF.tmr.Stop()
    DISPOSE(SELF.tmr)
  END
  
TAnimatedLabel.Init           PROCEDURE(SIGNED pFeq)
ctrlType                        LONG, AUTO
bIsValidType                    BOOL, AUTO
  CODE
  ctrlType = pFeq{PROP:Type}
  bIsValidType = CHOOSE(INLIST(ctrlType, CREATE:prompt, CREATE:string, CREATE:sstring) > 0)
  ASSERT(bIsValidType)
  IF NOT bIsValidType
    RETURN
  END
 
  SELF.bHidden = pFeq{PROP:Hide}

  PARENT.Init(pFeq)
  SELF.Reset()

TAnimatedLabel.Reset          PROCEDURE()
  CODE
  SELF.SetText(SELF.feq{PROP:Text})
  
  IF SELF.bHidden
    SELF.Hide()
  ELSE
    SELF.Show()
  END

TAnimatedLabel.GetChars       PROCEDURE(STRING pPropText)
cIndex                          SIGNED, AUTO
char                            STRING(1), AUTO
chars                           CSTRING(256), AUTO
  CODE
  ! Get text length;  "&" not included (means next char is underlined).
  ! For now don't consider multiple &&&&
  chars = ''
  LOOP cIndex = 1 TO LEN(pPropText)
    char = SUB(pPropText, cIndex, 1)
    IF char <> '&'
      chars = chars & char
    END
  END
  
  RETURN chars
  
TAnimatedLabel.SetText        PROCEDURE(STRING pText)
winpix                          TWinPix
dummyCtrl                       TDummyPrompt
ctrlType                        LONG, AUTO
chars                           STRING(255), AUTO
feq                             SIGNED, AUTO
cIndex                          SIGNED, AUTO
lf                              LIKE(TLOGFONT), AUTO
wp                              LIKE(TWINDOWPOS), AUTO
  CODE
!  al::DebugInfo('SetText')
  ASSERT(SELF.Feq)
  IF NOT SELF.Feq
    !-- not initialized
    RETURN
  END
  
  !-- Destroy all created controls
  IF SELF.nChars > 0
    DESTROY(SELF.chars[1], SELF.chars[SELF.nChars])
    SELF.nChars = 0
  END
  
  chars = SELF.GetChars(pText)
  SELF.nChars = LEN(CLIP(chars))
  SELF.nCurChar = 0

  ! Get 1 space char width
  dummyCtrl.Init(SELF.feq, pText)
  SELF.spaceWidth = dummyCtrl.SpaceWidth()

  ctrlType = SELF.Feq{PROP:Type}

  LOOP cIndex = 1 TO SELF.nChars
    feq = CREATE(0, ctrlType, SELF.feq{PROP:Parent})
    feq{PROP:Trn} = SELF.feq{PROP:Trn}
    
    IF pText[cIndex] <> '&'
      feq{PROP:Text} = chars[cIndex]
    ELSE
      feq{PROP:Text} = '&'& chars[cIndex]
    END
    SELF.chars[cIndex] = feq
  END
  
  al::GetLogFont(SELF.Feq{PROP:Handle}, lf)
  SELF.SetFont(lf)
  
  GETPOSITION(SELF.feq, wp.x, wp.y, wp.cx, wp.cy)
  SELF.SetPosition(wp)

TAnimatedLabel.SetFont        PROCEDURE(TLOGFONT lf)
cIndex                          LONG, AUTO
  CODE
!  al::DebugInfo('SetFont')
  ASSERT(SELF.Feq)
  IF NOT SELF.Feq
    !-- not initialized
    RETURN
  END
  
  LOOP cIndex = 1 TO SELF.nChars
    SETFONT(SELF.chars[cIndex], lf.lfFaceName, lf.lfHeight, SELF.feq{PROP:FontColor}, lf.lfWeight + lf.lfItalic * FONT:italic + lf.lfUnderline * FONT:underline + lf.lfStrikeOut * FONT:strikeout, lf.lfCharset)
    SELF.chars[cIndex]{PROP:Color} = SELF.feq{PROP:Color}
  END

TAnimatedLabel.SetPosition    PROCEDURE(TWINDOWPOS wp)
winpix                          TWinPix
feq                             SIGNED, AUTO
x                               SIGNED, AUTO
w                               UNSIGNED, AUTO
cIndex                          SIGNED, AUTO
  CODE
  ASSERT(SELF.Feq)
  IF NOT SELF.Feq
    !-- not initialized
    RETURN
  END
  
  x = wp.x
  
  LOOP cIndex = 1 TO SELF.nChars
    feq = SELF.chars[cIndex]
    IF feq{PROP:Text}
      w = _nopos  !-- default width
    ELSE
      w = SELF.spaceWidth
    END
    SETPOSITION(feq, x, wp.y, w, wp.cy)
    
    !-- if PROMPT width > default width, enlarge last char width
    IF cIndex = SELF.nChars AND (wp.x + wp.cx) > x
      w = (wp.x + wp.cx) - x
      SETPOSITION(feq, x, wp.y, w, wp.cy)
    END  
  
    x += feq{PROP:Width}
  END
  
  !-- restore hidden state
!    IF BAND(lpwp.flags, SWP_HIDEWINDOW)
!      al::DebugInfo('WM_WINDOWPOSCHANGED HIDE')
!    ELSE  
!      al::DebugInfo('WM_WINDOWPOSCHANGED SHOW')
!    END
!  IF BAND(wp.flags, SWP_HIDEWINDOW)
  IF SELF.bHidden
    SELF.Hide()
  ELSE
    SELF.Show()
  END
  
TAnimatedLabel.Show           PROCEDURE()
cIndex                          LONG, AUTO
feq                             SIGNED, AUTO
  CODE
  ASSERT(SELF.Feq)
  IF NOT SELF.Feq
    !-- not initialized
    RETURN
  END
  
  SELF.Feq{PROP:Hide} = TRUE
      
  LOOP cIndex = 1 TO SELF.nChars
    feq = SELF.chars[cIndex]
    IF INRANGE(feq{PROP:Xpos}, SELF.feq{PROP:Xpos}, SELF.feq{PROP:Xpos} + SELF.feq{PROP:Width})
      feq{PROP:Hide} = FALSE
    ELSE
      feq{PROP:Hide} = TRUE
      al::DebugInfo('Show, hidden '& cIndex)
    END
  END
  
  SELF.bHidden = FALSE

TAnimatedLabel.Hide           PROCEDURE()
cIndex                          LONG, AUTO
  CODE
  ASSERT(SELF.Feq)
  IF NOT SELF.Feq
    !-- not initialized
    RETURN
  END
  al::DebugInfo('Hide')
  
  SELF.bHidden = TRUE

  SELF.Feq{PROP:Hide} = TRUE
      
!  LOOP cIndex = 1 TO SELF.nChars
!    SELF.chars[cIndex]{PROP:Hide} = TRUE
!  END
  HIDE(SELF.chars[1], SELF.chars[SELF.nChars])

  SELF.bHidden = TRUE

TAnimatedLabel.Start          PROCEDURE(LONG pInterval, LONG pPauseTicks = 0)
  CODE
  SELF.nPauseTicks = pPauseTicks
  SELF.tmr.Interval(pInterval)
  SELF.tmr.Start()
  
TAnimatedLabel.Stop           PROCEDURE()
  CODE
  SELF.tmr.Stop()
  SELF.Reset()

TAnimatedLabel.ITmrCallBack.OnTick    PROCEDURE()
  CODE
  SELF.OnTick()
  
TAnimatedLabel.OnTick         PROCEDURE()
  CODE
  !-- actual animation in derived class
  RETURN
  
!endregion
  
!region TWave
TWave.Setup                   PROCEDURE(LONG pColor, SIGNED pFontDiff)
winpix                          TWinPix
feq                             SIGNED, AUTO
dy                              SIGNED, AUTO
  CODE
  SELF.nColor = pColor
  SELF.nFontDiff = pFontDiff
  RETURN 

TWave.OnTick                  PROCEDURE()
winpix                          TWinPix
feq                             SIGNED, AUTO
cIndex                          LONG, AUTO
h1                              SIGNED, AUTO
h2                              SIGNED, AUTO
dy                              SIGNED, AUTO
  CODE
  IF SELF.nCurChar = SELF.nChars
    !-- reset last char
    feq = SELF.chars[SELF.nCurChar]
    IF feq{PROP:FontSize} <> SELF.feq{PROP:FontSize}
      SETFONT(feq,, SELF.feq{PROP:FontSize}, SELF.feq{PROP:FontColor}, SELF.feq{PROP:FontStyle})
      feq{PROP:Color} = SELF.feq{PROP:Color}
      SETPOSITION(feq,, SELF.feq{PROP:Ypos},, SELF.feq{PROP:Height})
    END
    
    IF SELF.nPauseTicks > 0
      IF SELF.nPauseElapsed < SELF.nPauseTicks
        SELF.nPauseElapsed += 1
        RETURN
      END
    END
  END
  
  SELF.nPauseElapsed = 0

  IF SELF.nCurChar > 0
    !-- reset current char
    feq = SELF.chars[SELF.nCurChar]
    IF feq{PROP:FontSize} <> SELF.feq{PROP:FontSize}
      SETFONT(feq,, SELF.feq{PROP:FontSize}, SELF.feq{PROP:FontColor}, SELF.feq{PROP:FontStyle})
      feq{PROP:Color} = SELF.feq{PROP:Color}
      SETPOSITION(feq,, SELF.feq{PROP:Ypos},, SELF.feq{PROP:Height})
    END
  END
    
  SELF.nCurChar += 1
  IF SELF.nCurChar > SELF.nChars
    SELF.nCurChar = 1
  END
  
  !-- search for next non-whitespace char
  LOOP cIndex = SELF.nCurChar TO SELF.nChars
    feq = SELF.chars[cIndex]
    IF feq{PROP:Text} <> ''
      SELF.nCurChar = cIndex
      BREAK
    ELSE
      !-- set background
      SETFONT(feq,, SELF.feq{PROP:FontSize}, SELF.feq{PROP:FontColor}, SELF.feq{PROP:FontStyle})
      feq{PROP:Color} = SELF.feq{PROP:Color}
      SETPOSITION(feq,, SELF.feq{PROP:Ypos},, SELF.feq{PROP:Height})
    END
  END
  
  !-- increase char size and style (weight)
  feq = SELF.chars[SELF.nCurChar]
  h1 = feq{PROP:Height}
  feq{PROP:NoWidth} = 1
  feq{PROP:NoHeight} = 1
  SETFONT(feq,, SELF.feq{PROP:FontSize} + SELF.nFontDiff, SELF.nColor, SELF.feq{PROP:FontStyle} + 300)
  !-- vertical alignment
  h2 = feq{PROP:Height}
  dy = h2 - h1
  SETPOSITION(feq,, SELF.feq{PROP:Ypos} - dy / 2)
!endregion
  
!region TTicker
TTicker.OnTick                PROCEDURE()
winpix                          TWinPix
cIndex                          BYTE, AUTO
feq                             SIGNED, AUTO
xPos                            SIGNED, AUTO
  CODE
  IF SELF.nCurChar = SELF.nChars
    IF SELF.nPauseTicks > 0
      IF SELF.nPauseElapsed < SELF.nPauseTicks
        SELF.nPauseElapsed += 1
        RETURN
      END
    END
  END
  
  SELF.nPauseElapsed = 0

  SELF.nCurChar += 1
  IF SELF.nCurChar > SELF.nChars
    SELF.nCurChar = 1
  END
  
  IF SELF.chars[SELF.nCurChar]{PROP:Text} = ''
    SELF.nCurChar += 1
    IF SELF.nCurChar > SELF.nChars
      SELF.nCurChar = 1
    END
  END
  
  !-- hide all
  IF SELF.nCurChar = 1
    HIDE(SELF.chars[1], SELF.chars[SELF.nChars])
  END
  
  !-- find X position of 1st visible char
  xPos = SELF.Feq{PROP:Xpos} + SELF.Feq{PROP:Width}
  LOOP cIndex = 1 TO SELF.nCurChar
    xPos -= SELF.chars[cIndex]{PROP:Width}
  END
  
  !-- move visible chars to the next char pos left
  LOOP cIndex = 1 TO SELF.nCurChar
    SETPOSITION(SELF.chars[cIndex], xPos)
    xPos += SELF.chars[cIndex]{PROP:Width}
  END

  !-- unhide current char
  UNHIDE(SELF.chars[SELF.nCurChar])
!endregion
  
!region TMosaic
TMosaic.OnTick                PROCEDURE()
cIndex                          BYTE, AUTO
feq                             SIGNED, AUTO
  CODE
  IF SELF.nCurChar = 0
    !-- first run, hide all
    HIDE(SELF.chars[1], SELF.chars[SELF.nChars])
    SELF.nCurChar = 1
    RETURN
  END

  IF SELF.nCurChar > SELF.nChars
    !-- all chars unhidden, make a pause
    IF SELF.nPauseTicks > 0
      IF SELF.nPauseElapsed < SELF.nPauseTicks
        SELF.nPauseElapsed += 1
      ELSE
        SELF.nCurChar = 0
      END

      RETURN
    ELSE
      SELF.nCurChar = 0
      RETURN
    END
  END
  
  !-- subsequent call, show random char
  
  SELF.nPauseElapsed = 0
  
  LOOP
    cIndex = RANDOM(1, SELF.nChars)
    feq = SELF.chars[cIndex]
    IF feq{PROP:Hide} = TRUE
      feq{PROP:Hide} = FALSE
      
      SELF.nCurChar += 1
      RETURN
    END
  END
!endregion
  
!region TGradient
TGradient.Setup               PROCEDURE(LONG pstartColor, SIGNED pEndColor)
  CODE
  SELF.startColor = pstartColor
  SELF.endColor = pEndColor

TGradient.OnTick              PROCEDURE()
cIndex                          BYTE, AUTO
feq                             SIGNED, AUTO
startRGB                        GROUP, PRE(startRGB), OVER(SELF.startColor)
R                                 BYTE
G                                 BYTE
B                                 BYTE
                                END
endRGB                          GROUP, PRE(endRGB), OVER(SELF.endColor)
R                                 BYTE
G                                 BYTE
B                                 BYTE
                                END
nextColor                       LONG, AUTO
nextRGB                         GROUP, PRE(nextRGB), OVER(nextColor)
R                                 BYTE
G                                 BYTE
B                                 BYTE
                                END
  CODE
  IF SELF.nCurChar = 0
    !-- reset colors
    LOOP cIndex = 1 TO SELF.nChars
      SETFONT(SELF.chars[cIndex],,, SELF.Feq{PROP:FontColor})
    END
    SELF.nCurChar = 1
    RETURN
  ELSIF SELF.nCurChar > SELF.nChars
    IF SELF.nPauseTicks > 0
      IF SELF.nPauseElapsed < SELF.nPauseTicks
        SELF.nPauseElapsed += 1
        RETURN
      ELSE
        SELF.nCurChar = 0
        RETURN
      END
    END
  END
  
  SELF.nPauseElapsed = 0

  IF SELF.chars[SELF.nCurChar]{PROP:Text} = ''
    SELF.nCurChar += 1
    IF SELF.nCurChar > SELF.nChars
      SELF.nCurChar = 1
    END
  END
  
  nextRGB:R = startRGB:R + ((endRGB:R - startRGB:R) * SELF.nCurChar / SELF.nChars)
  nextRGB:G = startRGB:G + ((endRGB:G - startRGB:G) * SELF.nCurChar / SELF.nChars)
  nextRGB:B = startRGB:B + ((endRGB:B - startRGB:B) * SELF.nCurChar / SELF.nChars)
  
  SETFONT(SELF.chars[SELF.nCurChar],,, nextColor)
  SELF.nCurChar += 1
!endregion

!region TWheel
TWheel.Init                   PROCEDURE(SIGNED pFeq)
winpix                          TWinPix
PI                              EQUATE(3.1415926535898)     !The value of PI
alpha                           REAL, AUTO    !angle in radians
r                               SIGNED, AUTO  !radius
cIndex                          BYTE, AUTO
  CODE
  PARENT.Init(pFeq)
  
  CLEAR(SELF.Points)
  
  alpha = 2 * PI / SELF.nChars
  r = SELF.feq{PROP:Width} / 2
  
  LOOP cIndex = 1 TO SELF.nChars
    SELF.Points[1, cIndex] = r * COS(PI - (alpha * (cIndex - 1)))
    SELF.Points[2, cIndex] = r * SIN(PI - (alpha * (cIndex - 1)))
  END

TWheel.OnTick                 PROCEDURE()
winpix                          TWinPix
cIndex                          BYTE, AUTO
pIndex                          BYTE, AUTO
feq                             SIGNED, AUTO
x0                              SIGNED, AUTO
y0                              SIGNED, AUTO
xPos                            SIGNED, AUTO
yPos                            SIGNED, AUTO
  CODE
  IF SELF.nCurChar = SELF.nChars
    IF SELF.nPauseTicks > 0
      IF SELF.nPauseElapsed < SELF.nPauseTicks
        SELF.nPauseElapsed += 1
        RETURN
      END
    END
  END
  
  SELF.nPauseElapsed = 0

  SELF.nCurChar += 1
  IF SELF.nCurChar > SELF.nChars
    SELF.nCurChar = 1
  END
  
  !-- hide all
  HIDE(SELF.chars[1], SELF.chars[SELF.nChars])
  
  !-- center point of the wheel
  x0 = SELF.feq{PROP:Xpos} + SELF.feq{PROP:Width} / 2
  y0 = SELF.feq{PROP:Ypos}
  
  !-- move visible chars to the next char pos left
  LOOP pIndex = 1 TO SELF.nChars
    xPos = x0 + SELF.Points[1, pIndex]
    yPos = y0 - SELF.Points[2, pIndex]

    cIndex = pIndex + (SELF.nCurChar - 1)
    IF cIndex > SELF.nChars
      cIndex -= SELF.nChars
    END
    feq = SELF.chars[cIndex]

    SETPOSITION(feq, xPos, yPos)
  END

  !-- unhide all
  UNHIDE(SELF.chars[1], SELF.chars[SELF.nChars])
!endregion
