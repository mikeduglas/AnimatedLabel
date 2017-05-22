  OMIT('***')
  * Animated Label v1.01
  * Created by: <Mike Duglas> mikeduglas@yandex.ru
  ***

  INCLUDE('svapi.inc'), ONCE

  !-- EasyDotNet
  INCLUDE('ednWinFormsTimer.inc'), ONCE
  INCLUDE('ednDateTime.inc'), ONCE

  MAP
    MODULE('AnimLabel.clw')
      al::DebugInfo(STRING s)
    END
  END

!region WINDOWPOS
TWINDOWPOS                    GROUP, TYPE
hwnd                            HWND
hwndInsertAfter                 HWND
x                               LONG
y                               LONG
cx                              LONG
cy                              LONG
flags                           ULONG
                              END

!endregion

!region LOGFONT
LF_FACESIZE                   EQUATE(32)

TLOGFONT                      GROUP, TYPE
lfHeight                        LONG
lfWidth                         LONG
lfEscapement                    LONG
lfOrientation                   LONG
lfWeight                        LONG
lfItalic                        BYTE
lfUnderline                     BYTE
lfStrikeOut                     BYTE
lfCharSet                       BYTE
lfOutPrecision                  BYTE
lfClipPrecision                 BYTE
lfQuality                       BYTE
lfPitchAndFamily                BYTE
lfFaceName                      CSTRING(LF_FACESIZE)
                              END
!endregion

ILblCallBack                  INTERFACE
WndProc                         PROCEDURE(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam), LONG
                              END

ITmrCallBack                  INTERFACE
OnTick                          PROCEDURE()
                              END


!!!<summary>Sets Window{PROP:Pixels}=TRUE in .ctor, restores in .dtor</summary>
TWinPix                       CLASS, TYPE, MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
bPropPixels                     BOOL, PRIVATE
Construct                       PROCEDURE()
Destruct                        PROCEDURE()
                              END

TLabelBase                    CLASS, IMPLEMENTS(ILblCallBack), TYPE, MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
feq                             SIGNED, PROTECTED
W                               &WINDOW, PROTECTED
hwnd                            HWND, PROTECTED
wndProcAddr                     LONG, PRIVATE

Init                            PROCEDURE(SIGNED pFeq), VIRTUAL

WndProc                         PROCEDURE(HWND hWnd, ULONG wMsg, UNSIGNED wParam, LONG lParam), LONG, PROTECTED, VIRTUAL
SetText                         PROCEDURE(STRING pText), PROTECTED, VIRTUAL
SetPosition                     PROCEDURE(TWINDOWPOS wp), PROTECTED, VIRTUAL
SetFont                         PROCEDURE(TLOGFONT lf), PROTECTED, VIRTUAL
                              END

TAnimationTimer               CLASS(TWinFormsTimer), TYPE, MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
ctrl                            &ITmrCallBack, PRIVATE
tickCounter                     LONG, PRIVATE

BindCtrl                        PROCEDURE(ITmrCallBack pCtrl)
GetTickCounter                  PROCEDURE(), LONG
ResetTickCounter                PROCEDURE()

Tick                            PROCEDURE(), PROTECTED, DERIVED
                              END

!!!<summary>Abstract class. Derived classes should implement OnTick() method.</summary>
TAnimatedLabel                CLASS(TLabelBase), IMPLEMENTS(ITmrCallBack), TYPE, MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
chars                           SIGNED, DIM(255), PROTECTED !-- max text length 255
nChars                          BYTE, PROTECTED             !-- actual length
spaceWidth                      UNSIGNED, PROTECTED
bHidden                         BOOL, PROTECTED

tmr                             &TAnimationTimer, PROTECTED
nPauseTicks                     LONG, PROTECTED
nPauseElapsed                   LONG, PROTECTED
nCurChar                        BYTE, PROTECTED

Construct                       PROCEDURE()
Destruct                        PROCEDURE()

GetChars                        PROCEDURE(STRING pPropText), STRING, PROTECTED

Init                            PROCEDURE(SIGNED pFeq), DERIVED
Reset                           PROCEDURE()

SetText                         PROCEDURE(STRING pText), PROTECTED, DERIVED
SetPosition                     PROCEDURE(TWINDOWPOS wp), PROTECTED, DERIVED
SetFont                         PROCEDURE(TLOGFONT lf), PROTECTED, DERIVED
Show                            PROCEDURE(), VIRTUAL
Hide                            PROCEDURE(), VIRTUAL

Start                           PROCEDURE(LONG pInterval, LONG pPauseTicks = 0)
Stop                            PROCEDURE()

!-- events
OnTick                          PROCEDURE(), PROTECTED, VIRTUAL
                              END

TWave                         CLASS(TAnimatedLabel), TYPE, MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
nColor                          LONG, PRIVATE
nFontDiff                       SIGNED, PRIVATE

Construct                       PROCEDURE()
Init                            PROCEDURE(SIGNED pFeq, LONG pColor, SIGNED pFontDiff)

!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

TTicker                       CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

TMosaic                       CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

TGradient                     CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
startColor                      LONG, PRIVATE
endColor                        LONG, PRIVATE

Construct                       PROCEDURE()
Init                            PROCEDURE(SIGNED pFeq, LONG pStartColor, SIGNED pEndColor)

!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

TWheel                        CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
Points                          SIGNED, DIM(2, 255), PRIVATE  !(x,y) of each char

Init                            PROCEDURE(SIGNED pFeq), DERIVED

!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

!static (not animated) label with 3D look
TLabel3D                      CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
m_shadow                        &TAnimatedLabel, PROTECTED
m_shadowColor                   LONG, PRIVATE
m_shadowDX                      LONG, PRIVATE
m_shadowDY                      LONG, PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE()
Init                            PROCEDURE(SIGNED pFeq), DERIVED
Init                            PROCEDURE(SIGNED pFeq, LONG pShadowColor, LONG pDX, LONG pDY)
Show                            PROCEDURE(), DERIVED
Hide                            PROCEDURE(), DERIVED
                              END

TDigitalClock                 CLASS(TAnimatedLabel), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
m_DateTime                      &TSystemDateTime, PRIVATE
m_timeFmt                       STRING(32), PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE()
Init                            PROCEDURE(SIGNED pFeq), DERIVED
Init                            PROCEDURE(SIGNED pFeq, STRING pTimeFmt)

!-- events
OnTick                          PROCEDURE(), PROTECTED, DERIVED
                              END

TGradientProgress             CLASS(TGradient), TYPE,  MODULE('AnimLabel.clw'), LINK('AnimLabel.clw')
Init                            PROCEDURE(SIGNED pFeq, LONG pStartColor, SIGNED pEndColor)
                              END
