@echo off
SETLOCAL
IF /I "%1"=="/?" (
echo.
echo Makeboot ���� ����������������ļ��Ĺ���
echo.
echo makebt32 [/easteregg] [/Ignmissingfile] [/FromFloppy] [/UseDOSNET] [/DoubleBootFont]
echo          [/Compress] [/Bigger1stFloppy]
echo.
echo Ĭ������£�����ʹ�ò�����Makeboot ���߽��Զ�ѯ�ʲ��ռ�������Ϣ��
echo.
echo   /easteregg         ָ�� Makeboot Ӧ���޸� txtsetup.sif��������Ĭ�����صĿ���
echo                      ��Ļ������
echo   /Ignmissingfile    ָ�� Makeboot �����ļ�������ʱ�������ƣ���ȱʧ�ļ�����������
echo                      ���ļ��С���Makeboot ����֪���ļ�����
echo   /Ver2old           �������ڳ���Ϊʮ���Ͼɵ�ϵͳ������������ʱ���뿼��ʹ�ô�ѡ�
echo   /UseDOSNET         ָ�� Makeboot �� dosnet.inf �л�ȡӦ���Ƶ��ļ��б�
echo   /DoubleBootFont    ָ�� Makeboot Ӧ�������� BootFont.bin������У�����ͬλ��
echo                      �Խ��Ǳ�ڵ��������⡣����ָ�� /UseDOSNET ʱ���裩
echo   /Compress          ������̲����Է��������ļ�����ʹ�ô�ѡ��������ѹ�������ļ��ͷ�
echo                      �ռ䡣������ɸ��ƺ�ɵ���ʹ�ã�
echo   /Bigger1stFloppy   ����һ�����̣�����������һ�����滻Ϊ1.68MB��С��������ɸ���
echo                      ��ɵ���ʹ�ã�
echo.
goto :eof
)
 FOR /F %%C IN ("%~DP0") DO (
  IF /I  NOT "%%~C"=="%~DP0" (
    echo ����Ŀ¼���ƴ��ڿո񣬽ű��޷�����.
    goto EOF
  )
 )
REM ________________________________________________________________

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (

    echo �������ԱȨ��...

    goto UACPrompt

) else ( goto gotAdmin )

:UACPrompt

    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"

    echo UAC.ShellExecute "%~s0", "%1 %2 %3 %4 %5 %6 %7 %8 %9", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"

    exit /B

:gotAdmin

    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )

    pushd "%CD%"

    CD /D "%~dp0"

REM ________________________________________________________________
VERIFY OTHER 2>nul
SETLOCAL ENABLEDELAYEDEXPANSION
IF ERRORLEVEL 1 (
echo �ű�������Ϊϵͳ�汾���ɶ��޷����У�������ǽ�����ֱ�ӹرմ˴��ڡ�
echo �����Ҫ����������ô
pause
)
set workplace=%~dp0Sources\
FOR %%A IN (%1 %2 %3 %4 %5 %6 %7 %8 %9) DO (
 IF /I "%%A"=="/easteregg" set EnableGUI=true
 IF /I "%%A"=="/Ignmissingfile" set Ignmissingfile=true
 IF /I "%%A"=="/Ver2old" set IgnAllCheck=true
 IF /I "%%A"=="/UseDOSNET" set UseDosnet=true
 IF /I "%%A"=="/Compress" set Compress=true
 IF /I "%%A"=="/DoubleBootFont" set DoubleBootFont=true
 IF /I "%%A"=="/Bigger1stFloppy" goto :Replace
)
IF "%UseDosnet%"=="true" (
  call %workplace%dosnet.cmd
  goto :EnableGUI
)
IF "%Compress%"=="true" (
  call %workplace%Compress.cmd
  goto :end
)
:loop
set SIFDIR=PlaceHolder
set /p SIFDIR=������� txtsetup.sif ��·���Լ����� 

for /F %%C in ("%SIFDIR%") DO (
 IF /I not "%%C"=="%SIFDIR%" (
  echo ·�����ڿո�������һ���������ո��Ŀ¼·�������ԡ�
  goto loop
 )
)

echo %SIFDIR% | find /i "txtsetup.sif" 1>nul || (
 if not exist %SIFDIR%\txtsetup.sif (
  echo �����������·�������Ǹոճ�����Ѱ�� %SIFDIR%\txtsetup.sif��
  echo ���ǣ������������·���������Ҳ��� txtsetup.sif �ļ�����ȷ��·����ȷ������һ�Ρ�
  goto :loop
 ) else goto :made
)

if not exist %SIFDIR% (
 echo �����������·�������Ǹոճ�����Ѱ�� %SIFDIR%��
 echo ���ǣ������������·���������Ҳ��� txtsetup.sif �ļ�����ȷ��·����ȷ������һ�Ρ�
 goto loop
 ) else (
   set SIFFile=%SIFDIR%
   goto :AC
 )
)
:made
set SIFFile=%SIFDIR%\txtsetup.sif
:AC
set FileDir=PlaceHolder
set /p FileDir=�������ļ���Ŀ¼�Լ����� 
FOR /F %%C IN ("%FileDir%") DO (
  IF /I  NOT "%%~C"=="%FileDir%" (
  echo ·�����ܰ����ո�����һ���������ո��Ŀ¼·�������ԡ�
  goto :AC
 )
)
if not exist %FileDir%\ (
echo ��Ŀ¼�����ڡ������ԡ�
goto :AC
)
dir %FileDir% /b|find /v "0471391E">nul|| goto :AC2
echo Ŀ¼�����ǿյġ�����һ���յ�Ŀ¼·�������ԡ�
goto :AC
:AC2
set Dir=%FileDIR%\
rem Prepare
set count=0
set disknumber=0
FOR /F "tokens=1 delims=_= " %%N in ('findstr /B "_1 _2 _3 _4 _5 _6 _7 _8 _9 1_ 2_ 3_ 4_ 5_ 6_ 7_ 8_ 9_" %SIFFile%') do (
 IF /I !disknumber! GTR %%N (
  goto :Next 
 ) else (
  set disknumber=%%N
 )
)
:Next
FOR /L %%n IN (1,1,%disknumber%) DO (
 md %Dir%%%n
 fsutil file createNew %Dir%%%n\DISK10%%n 0
)
:temp
cls
set temp=%random%.txt
set list=%random%.txt
title %Dir%
echo ��������ͨ�� txtsetup.sif �����ļ��б�
echo �⽫��Ҫ��Լ3-5���ӵ�ʱ�䣬���Ժ�
set /A Skipline=2
set /A thousand=0
set /A readlines=0
FOR /F "skip=%Skipline% delims=[]" %%i in ('find /N "[SourceDisksFiles.x86]" %SIFFile%') do (
 set Skipline=%%i
 goto :continue
 )
:continue
if /I %readlines%==1000 (
 set /A thousand+=1
 set /A readlines=0
 echo �Ѷ�ȡ!thousand!000�����ݡ�
)
FOR /F "skip=%Skipline% tokens=1,2 delims== " %%A in (%SIFFile%) do (
 echo %%A | find "[" > NUL && goto :afterthis
 echo %%B | findstr "_1 _2 _3 _4 _5 _6 _7 _8 _9 1_ 2_ 3_ 4_ 5_ 6_ 7_ 8_ 9_"> NUL && FOR /F "tokens=2 delims=,_" %%N in ("%%B") do (
  echo %%B | find /I "x" > NUL && (
   SET /A Skipline+=1
   set /A readlines+=1
   goto :continue
  )
  echo %%A#%%N>>%workplace%%temp%
 )
 SET /A Skipline+=1
 set /A readlines+=1
 goto :continue
)
:afterthis
set /A Skipline=2
FOR /F "skip=%Skipline% delims=[]" %%i in ('find /I /N "[SourceDisksFiles]" %SIFFile%') do (
 set Skipline=%%i
 goto :doagain
 )
:doagain
if /I %readlines%==1000 (
 set /A thousand+=1
 set /A readlines=0
 echo �Ѷ�ȡ!thousand!000�����ݡ�
)
FOR /F "skip=%Skipline% tokens=1,2 delims== " %%A in (%SIFFile%) do (
 echo %%A | find "[" > NUL && goto :Reprocessing
 echo %%B | findstr "_1 _2 _3 _4 _5 _6 _7 _8 _9 1_ 2_ 3_ 4_ 5_ 6_ 7_ 8_ 9_"> NUL && FOR /F "tokens=2 delims=,_" %%N in ("%%B") do (
  echo %%B | find /I "x" > NUL && (
   SET /A Skipline+=1
   set /A readlines+=1
   goto :doagain
  )
  echo %%A#%%N>>%workplace%%temp%
 )
 SET /A Skipline+=1
 set /A readlines+=1
 goto :doagain
)
:Reprocessing
echo ����ȡ��%thousand%%readlines%�����ݡ�
findstr /V /R ".*fon kbd.*dll c.*nls" %workplace%%temp%>>%workplace%%list%
del %workplace%%temp%
FOR /F "tokens=1,2 delims== " %%A in ('findstr /B "vgaoem.fon" %SIFFile%') do (
 FOR /F "tokens=2 delims=,_" %%N in ("%%B") do (
  echo %%A#%%N>>%workplace%%list%
 )
)
FOR /F "tokens=1,2 delims== " %%A in ('findstr /B "kbdhid.sys" %SIFFile%') do (
 FOR /F "tokens=2 delims=,_" %%N in ("%%B") do (
  echo %%A#%%N>>%workplace%%list%
 )
)

rem Ѱ���ļ�����ȷ�����Ƕ����ڡ�
rem :CopyFile
FOR /F %%L in ("%SIFFile%") do set FilePath=%%~dpL
IF "%Ignmissingfile%"=="true" goto :IgnoreCheck
FOR /F "tokens=1 delims=#" %%F in (%workplace%%list%) do (
 if not exist %FilePath%%%~nF.* goto :Missingfile
)
goto :VIFCheck

:IgnoreCheck
set Missing=MissingFiles-%random%.txt
FOR /F "tokens=1,2 delims=#" %%F in (%workplace%%list%) do (
 if not exist %FilePath%%%~nF.* echo %%F#%%G>>%workplace%..\%Missing%
)

:VIFCheck
if not exist %FilePath%setupreg.hiv goto :Missingfile
if not exist %FilePath%SETUPLDR.BIN goto :Missingfile
if not exist %FilePath%SYSTEM32\SMSS.EXE goto :Missingfile
if not exist %FilePath%SYSTEM32\NTDLL.DLL goto :Missingfile
if not exist %FilePath%NTKRNLMP.EX? goto :Missingfile

rem ��ʼ�����ļ���
:Copy
FOR /F "tokens=1,2 delims=#" %%M in (%workplace%%list%) do (
 set CopyFile=%%M
 xcopy /Y /H %FilePath%!CopyFile:~0,-1!? %Dir%%%N\>>%workplace%..\MakeBoot.log
)
xcopy /h /Y %FilePath%SETUPLDR.BIN %Dir%1\>>%workplace%..\MakeBoot.log
xcopy /h /Y %SIFFile% %Dir%1\>>%workplace%..\MakeBoot.log
FOR /F "skip=2 tokens=1,2 delims=#" %%M in ('find /I "ntdll.dll" %workplace%%list%') do (
 del /f /q %Dir%%%N\ntdll.dll>>nul
 xcopy /h /Y %FilePath%SYSTEM32\NTDLL.DLL %Dir%%%N\SYSTEM32\>>%workplace%..\MakeBoot.log
 xcopy /h /Y %FilePath%SYSTEM32\SMSS.EXE %Dir%%%N\SYSTEM32\>>%workplace%..\MakeBoot.log
 xcopy /h /Y %FilePath%KBDUS.DLL %Dir%%%N\>>%workplace%..\MakeBoot.log
 set dbfont=%%N
)
FOR /F "skip=2 tokens=1,2 delims=#" %%M in ('find /I "ntfs.sys" %workplace%%list%') do (
 if exist %Dir%%%N\ntfs.sys (
  makecab /d compressiontype=lzx /d compressionmemory=21 /l %Dir%%%N\ %Dir%%%N\ntfs.sys>>%workplace%..\MakeBoot.log
  del /f /q %Dir%%%N\ntfs.sys>>nul
 )
)
echo ����ǰ�����������������̶�Ӧ�������ǣ�
echo Ӣ�Ĭ�ϵ� Beta ���ԣ��밴 E��
echo �����밴 J��
echo �����밴 K��
echo ���������밴 S��
echo ���������밴 T��
echo ���������밴 O��
choice /C EJKSTO /N
IF %errorlevel%==1 set NLS=Empty
IF %errorlevel%==2 set NLS=932
IF %errorlevel%==3 set NLS=949
IF %errorlevel%==4 set NLS=936
IF %errorlevel%==5 set NLS=950
IF %errorlevel%==6 set /p NLS=���������Զ�Ӧ�Ĵ���ҳ��š�ע�⣺����㲻��������˵����ʲô������������ļ���
FOR /F "skip=2 tokens=1,2 delims== " %%M in ('find /I "C_437.NLS" %SIFFile%') do (
 FOR /F "tokens=2 delims=,_" %%B in ("%%N") do (
  if exist %FilePath%C_437.NL? xcopy /h /Y %FilePath%C_437.NL? %Dir%%%B\>>%workplace%..\MakeBoot.log
  if exist %FilePath%C_1252.NL? xcopy /h /Y %FilePath%C_1252.NL? %Dir%%%B\>>%workplace%..\MakeBoot.log
  if not "%NLS%"=="Empty" (
   xcopy /h /Y %FilePath%C_%NLS%.NL? %Dir%%%B\>>%workplace%..\MakeBoot.log
   xcopy /h /Y %FilePath%bootfont.bin %Dir%1\>>%workplace%..\MakeBoot.log
  )
 )
)
FOR /F "tokens=1,2 delims== " %%A in ('findstr /I /B "KBDUS.DLL" %SIFFile%') do (
 FOR /F "tokens=2 delims=,_" %%N in ("%%B") do (
  xcopy /h /Y %FilePath%KBDUS.DLL %Dir%%%N\>>%workplace%..\MakeBoot.log
 )
)
IF "%DoubleBootFont%"=="true" (
 if exist %Dir%1\bootfont.bin (
  xcopy /h /Y %FilePath%bootfont.bin %Dir%%dbfont%\>>%workplace%..\MakeBoot.log
 )
)

rem ���� GUI Boot.
:EnableGUI
IF NOT "%EnableGUI%"=="true" goto :Floppy
find /I /N "/noguiboot" %Dir%1\txtsetup.sif>nul|| goto :Floppy
%workplace%EnableGUIBoot.vbs %Dir%1\txtsetup.sif
goto :Floppy

:Missingfile
echo ��⵽�ļ�ȱʧ���ű��޷�������
echo �����һ�������İ�װ�ļ��飬��ʹ�� "/Ignmissingfile" ������
echo �й���ϸ��Ϣ������������ļ���
goto :error

:Floppy
IF /I "%disknumber%" EQU "1" (
 xcopy %workplace%CDBOOT1.img %Dir%>>%workplace%..\MakeBoot.log
) ELSE (
 xcopy %workplace%CDBOOT1.img %Dir%>>%workplace%..\MakeBoot.log
 FOR /L %%n IN (2,1,%disknumber%) DO (
  echo f | xcopy %workplace%CDBOOTx.img %Dir%CDBOOT%%n.img>>%workplace%..\MakeBoot.log
 )
)
goto :end
:Replace
set Replace=PlaceHolder
set /p Replace=�����Ѵ���ļ���Ŀ¼�Լ�����
if not exist %Replace%\CDBOOT1.img (
 echo ��Ŀ¼���ǹ���Ŀ¼�������ԡ�
 goto :Replace
)
xcopy /Y %workplace%CDBOOTB.img %Replace%\CDBOOT1.img
exit
:error
echo �ű��޷����������ڽ����������ԡ�
:end
del %workplace%%list%>nul
if exist %Missing% echo ȱʧ�ļ������������͵� %Missing%��
echo �밴������˳���
pause>nul
