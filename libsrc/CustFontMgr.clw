  MEMBER

  INCLUDE('CustFontMgr.inc'), ONCE

  MAP
    MODULE('WinAPI')
      fm::AddFontResourceEx(*CSTRING lpszFilename, ULONG fl, LONG pdv = 0), LONG, PASCAL, RAW, NAME('AddFontResourceExA')
      fm::RemoveFontResourceEx(*CSTRING lpszFilename, ULONG fl, LONG pdv = 0), LONG, PASCAL, RAW, NAME('AddFontResourceExA')
    END
  END


TCustomFontMgr.Construct      PROCEDURE()
  CODE
  SELF.Q &= NEW TFontsQ
  
TCustomFontMgr.Destruct       PROCEDURE()
qIndex                          LONG, AUTO
  CODE
  IF NOT SELF.Q &= NULL
    LOOP qIndex = RECORDS(SELF.Q) TO 1 BY -1
      GET(SELF.Q, qIndex)
      SELF.RemoveFont()
    END
    
    FREE(SELF.Q)
    DISPOSE(SELF.Q)
  END
  
TCustomFontMgr.AddFont        PROCEDURE(STRING pFontFile, LONG pFlags = FR_PRIVATE)
szFile                          CSTRING(256)
rc                              LONG, AUTO
  CODE
  szFile = LONGPATH(pFontFile)
  rc = fm::AddFontResourceEx(szFile, pFlags)
  IF rc > 0
    SELF.Q.Filename = pFontFile
    SELF.Q.Flag = pFlags
    ADD(SELF.Q)
    RETURN TRUE
  END
  
  RETURN FALSE
  
TCustomFontMgr.RemoveFont     PROCEDURE(STRING pFontFile, LONG pFlags = FR_PRIVATE)
  CODE
  SELF.Q.Filename = pFontFile
  SELF.Q.Flag = pFlags
  GET(SELF.Q, SELF.Q.Filename, SELF.Q.Flag)
  IF NOT ERRORCODE()
    RETURN SELF.RemoveFont()
  END
  
  RETURN FALSE

TCustomFontMgr.RemoveFont     PROCEDURE()
szFile                          CSTRING(256)
rc                              LONG, AUTO
  CODE
  szFile = CLIP(SELF.Q.Filename)
  rc = fm::RemoveFontResourceEx(szFile, SELF.Q.Flag)
  IF rc > 0
    DELETE(SELF.Q)
    RETURN TRUE
  END
  
  RETURN FALSE
