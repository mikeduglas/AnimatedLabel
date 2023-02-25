  PROGRAM
 
  PRAGMA('project(#pragma define(_ABCDllMode_ => 0))')
  PRAGMA('project(#pragma define(_ABCLinkMode_ => 1))')

  PRAGMA('project(#pragma define(_SVDllMode_ => 0))')
  PRAGMA('project(#pragma define(_SVLinkMode_ => 1))')
  !- link manifest
  PRAGMA('project(#pragma link(test.EXE.manifest))')

  INCLUDE('AnimLabel.inc'), ONCE
  INCLUDE('CustFontMgr.inc'), ONCE

  MAP
  END

Window                        WINDOW('Animated label demo'),AT(,,344,182),CENTER,GRAY,FONT('Calibri',12)
                                SHEET,AT(2,2,340,147),USE(?SHEET1)
                                  TAB('About'),USE(?TAB1)
                                    PROMPT('Product: '),AT(10,39),USE(?PROMPT1),TRN,FONT(,20),RIGHT
                                    PROMPT('Animated Label'),AT(68,39),USE(?lblProduct),TRN,FONT(,20)
                                    PROMPT('Author: '),AT(15,58),USE(?PROMPT2),TRN,FONT(,20),RIGHT
                                    PROMPT('Mike Duglas'),AT(68,58),USE(?lblAuthor),TRN,FONT(,20)
                                    PROMPT('Email: '),AT(23,76),USE(?PROMPT3),TRN,FONT(,20),RIGHT
                                    PROMPT('mikeduglas@yandex.ru'),AT(68,76),USE(?lblEmail),TRN,FONT(,20)
                                    PROMPT('Web: '),AT(28,95),USE(?PROMPT4),TRN,FONT(,20),RIGHT
                                    PROMPT('https://github.com/mikeduglas/AnimatedLabel'),AT(68,95),USE(?lblWWW), |
                                      TRN,FONT(,20)
                                    BUTTON('Animate!'),AT(279,124,54),USE(?bAnimateAbout)
                                  END
                                  TAB('Samples'),USE(?TAB2)
                                    PROMPT('Animated=lebal='),AT(220,58),USE(?lblWheel),TRN, |
                                      FONT(,12)
                                    PROMPT('Static 3D text'),AT(10,24),USE(?lblStatic),TRN,FONT(,42)
                                    STRING('Short time'),AT(10,62),USE(?lblClock1),TRN,FONT(,24,0CC6600H, |
                                      FONT:regular)
                                    STRING('Long time'),AT(10,83,,18),USE(?lblClock2),TRN,FONT(,24,0CC6600H, |
                                      FONT:regular)
                                    PROMPT('*'),AT(251,122),USE(?lblWait),TRN,FONT(,36)
                                    PROMPT('Progress Bar'),AT(10,124,228),USE(?lblProgress),TRN,FONT(,24)
                                    BUTTON('Animate!'),AT(279,124,54),USE(?bAnimateOthers),DEFAULT
                                  END
                                END
                                BUTTON('Close'),AT(286,158,47),USE(?bExit),STD(STD:Close)
                              END

ticker                        TTicker
wave                          TWave
mosaic                        TMosaic
gradient                      TGradient
wheel                         TWheel
label3D                       TLabel3D
clock1                        TDigitalClock
clock2                        TDigitalClock
progress                      TGradientProgress
wait                          TWaitIndicator

fontMgr                       TCustomFontMgr

  CODE  
  OPEN(Window)

  !-- register custom 'Digital-7 Mono' font
  fontMgr.AddFont('.\fonts\digital-7 (mono).ttf')
  
  !-- change clock font 
  ?lblClock1{PROP:FontName} = 'Digital-7 Mono'
  ?lblClock2{PROP:FontName} = 'Digital-7 Mono'

  !- initialize all animation labels
  ticker.Init(?lblProduct)
  wave.Init(?lblAuthor)   !-- default Red char, font + 4
  mosaic.Init(?lblEmail)
  gradient.Init(?lblWWW)  !-- default gradient from Red to Blue
  wheel.Init(?lblWheel)
  label3D.Init(?lblStatic)
  clock1.Init(?lblClock1, '@t7')
  clock2.Init(?lblClock2, '@t8')
  progress.Init(?lblProgress, 0098FB98h, COLOR:Green)
  wait.Init(?lblWait)
  
  ACCEPT 
    CASE ACCEPTED()
    OF ?bAnimateAbout
      ticker.Start(150, 20)             !-- tick every 150ms; pause 20 ticks
      wave.Start(50, 20)                !-- tick every 50ms;  pause 20 ticks
      mosaic.Start(100, 20)             !-- tick every 100ms; pause 20 ticks
      gradient.Start(50, 20)            !-- tick every 50ms;  pause 20 ticks
    OF ?bAnimateOthers
      wheel.Start(100, 10)
      label3D.Show()
      clock1.Start(500)
      clock2.Start(500)
      progress.Start(25, 2)
      wait.Start(100)
    END
  END
  