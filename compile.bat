@echo.
@echo Compiling...
asm6f drmario.asm drmario.nes
@IF ERRORLEVEL 1 GOTO failure
@echo.
@echo.
@echo Success!
@pause

@GOTO endbuild

:failure
@echo.
@echo Build error!
@pause

:endbuild