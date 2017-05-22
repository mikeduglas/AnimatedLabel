TFontsQ                       QUEUE, TYPE
Filename                        STRING(256)
Flag                            LONG
                              END

FR_PRIVATE                    EQUATE(10h)
FR_NOT_ENUM                   EQUATE(20h)

TCustomFontMgr                CLASS, TYPE, MODULE('CustFontMgr.clw'), LINK('CustFontMgr.clw')
Q                               &TFontsQ, PRIVATE

Construct                       PROCEDURE()
Destruct                        PROCEDURE()

AddFont                         PROCEDURE(STRING pFontFile, LONG pFlags = FR_PRIVATE), BOOL, PROC
RemoveFont                      PROCEDURE(STRING pFontFile, LONG pFlags = FR_PRIVATE), BOOL, PROC
RemoveFont                      PROCEDURE(), BOOL, PROC, PRIVATE  !- removes font currently selected in Q
                              END
