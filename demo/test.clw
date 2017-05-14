  PROGRAM
 
  PRAGMA('project(#pragma define(_ABCDllMode_ => 0))')
  PRAGMA('project(#pragma define(_ABCLinkMode_ => 1))')

  PRAGMA('project(#pragma define(_SVDllMode_ => 0))')
  PRAGMA('project(#pragma define(_SVLinkMode_ => 1))')
  !- link manifest
  PRAGMA('project(#pragma link(test.EXE.manifest))')

  INCLUDE('AnimLabel.inc'), ONCE

  MAP
  END

Window                        WINDOW('Animated label demo'),AT(,,344,182),CENTER,GRAY,FONT('Calibri',12)
                                PROMPT('Product: '),AT(10,14),USE(?PROMPT1),TRN,FONT(,20),RIGHT
                                PROMPT('Animated Label'),AT(68,14),USE(?lblProduct),TRN,FONT(,20)
                                PROMPT('Author: '),AT(15,33),USE(?PROMPT2),TRN,FONT(,20),RIGHT
                                PROMPT('Mike Duglas'),AT(68,33),USE(?lblAuthor),TRN,FONT(,20)
                                PROMPT('Email: '),AT(23,51),USE(?PROMPT3),TRN,FONT(,20),RIGHT
                                PROMPT('mikeduglas@yandex.ru'),AT(68,51),USE(?lblEmail),TRN,FONT(,20)
                                PROMPT('Web: '),AT(28,70),USE(?PROMPT4),TRN,FONT(,20),RIGHT
                                PROMPT('https://github.com/mikeduglas/AnimatedLabel'),AT(68,70),USE(?lblWWW),TRN, |
                                  FONT(,20)
                                PROMPT('Powered by*EASYDOTNET*'),AT(10,128),USE(?lblWheel),TRN,FONT(,12,,FONT:bold)
                                BUTTON('Animate!'),AT(220,158,54),USE(?bAnimate),DEFAULT
                                BUTTON('Close'),AT(286,158,47),USE(?bExit),STD(STD:Close)
                              END

ticker                        TTicker
wave                          TWave
mosaic                        TMosaic
gradient                      TGradient
wheel                         TWheel

  CODE
  OPEN(Window)
  
  ticker.Init(?lblProduct)

  wave.Init(?lblAuthor)
  wave.Setup(COLOR:Red, 4)              !-- Red char, font + 4

  mosaic.Init(?lblEmail)

  gradient.Init(?lblWWW)
  gradient.Setup(COLOR:Red, COLOR:Blue) !-- Gradient from Red to Blue

  wheel.Init(?lblWheel)
  
  ACCEPT 
    CASE ACCEPTED()
    OF ?bAnimate
      ticker.Start(150, 20)             !-- tick every 150ms; pause 20 ticks
      wave.Start(50, 20)                !-- tick every 50ms;  pause 20 ticks
      mosaic.Start(100, 20)             !-- tick every 100ms; pause 20 ticks
      gradient.Start(50, 20)            !-- tick every 50ms;  pause 20 ticks
      wheel.Start(120, 0)               !-- tick every 50ms;  pause 20 ticks
    END
  END
