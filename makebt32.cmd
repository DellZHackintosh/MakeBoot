@echo off
SETLOCAL
IF /I "%1"=="/?" (
echo.
echo Makeboot —— 获得启动软盘所需文件的工具
echo.
echo makebt32 [/easteregg] [/Ignmissingfile] [/FromFloppy] [/UseDOSNET] [/DoubleBootFont]
echo          [/Compress] [/Bigger1stFloppy]
echo.
echo 默认情况下，无需使用参数，Makeboot 工具将自动询问并收集所需信息。
echo.
echo   /easteregg         指定 Makeboot 应该修改 txtsetup.sif，来启动默认隐藏的开机
echo                      屏幕动画。
echo   /Ignmissingfile    指定 Makeboot 遇到文件不存在时继续复制，将缺失文件的名称输送
echo                      到文件中。（Makeboot 将告知您文件名）
echo   /Ver2old           当您正在尝试为十分老旧的系统制作启动软盘时，请考虑使用此选项。
echo   /UseDOSNET         指定 Makeboot 从 dosnet.inf 中获取应复制的文件列表。
echo   /DoubleBootFont    指定 Makeboot 应复制两个 BootFont.bin（如果有）至不同位置
echo                      以解决潜在的乱码问题。（当指定 /UseDOSNET 时无需）
echo   /Compress          如果磁盘不足以放下所有文件，请使用此选项来尝试压缩部分文件释放
echo                      空间。（仅完成复制后可单独使用）
echo   /Bigger1stFloppy   将第一个磁盘（可引导的那一个）替换为1.68MB大小。（仅完成复制
echo                      后可单独使用）
echo.
goto :eof
)
 FOR /F %%C IN ("%~DP0") DO (
  IF /I  NOT "%%~C"=="%~DP0" (
    echo 工作目录名称存在空格，脚本无法继续.
    goto EOF
  )
 )
REM ________________________________________________________________

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

if '%errorlevel%' NEQ '0' (

    echo 请求管理员权限...

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
echo 脚本可能因为系统版本过旧而无法运行，因此我们建议你直接关闭此窗口。
echo 如果仍要运行它，那么
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
set /p SIFDIR=输入包含 txtsetup.sif 的路径以继续。 

for /F %%C in ("%SIFDIR%") DO (
 IF /I not "%%C"=="%SIFDIR%" (
  echo 路径存在空格，请输入一个不包含空格的目录路径以重试。
  goto loop
 )
)

echo %SIFDIR% | find /i "txtsetup.sif" 1>nul || (
 if not exist %SIFDIR%\txtsetup.sif (
  echo 根据您输入的路径，我们刚刚尝试了寻找 %SIFDIR%\txtsetup.sif。
  echo 但是，按照您输入的路径，我们找不到 txtsetup.sif 文件。请确认路径正确后，再试一次。
  goto :loop
 ) else goto :made
)

if not exist %SIFDIR% (
 echo 根据您输入的路径，我们刚刚尝试了寻找 %SIFDIR%。
 echo 但是，按照您输入的路径，我们找不到 txtsetup.sif 文件。请确认路径正确后，再试一次。
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
set /p FileDir=输入存放文件的目录以继续。 
FOR /F %%C IN ("%FileDir%") DO (
  IF /I  NOT "%%~C"=="%FileDir%" (
  echo 路径不能包含空格。输入一个不包含空格的目录路径以重试。
  goto :AC
 )
)
if not exist %FileDir%\ (
echo 此目录不存在。请重试。
goto :AC
)
dir %FileDir% /b|find /v "0471391E">nul|| goto :AC2
echo 目录必须是空的。输入一个空的目录路径以重试。
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
echo 我们正在通过 txtsetup.sif 创建文件列表。
echo 这将需要大约3-5分钟的时间，请稍候。
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
 echo 已读取!thousand!000行内容。
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
 echo 已读取!thousand!000行内容。
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
echo 共读取了%thousand%%readlines%行内容。
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

rem 寻找文件，以确保它们都存在。
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

rem 开始复制文件。
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
echo 您当前正在制作的启动软盘对应的语言是？
echo 英语（默认的 Beta 语言）请按 E。
echo 日语请按 J。
echo 韩语请按 K。
echo 简体中文请按 S。
echo 繁体中文请按 T。
echo 其它语言请按 O。
choice /C EJKSTO /N
IF %errorlevel%==1 set NLS=Empty
IF %errorlevel%==2 set NLS=932
IF %errorlevel%==3 set NLS=949
IF %errorlevel%==4 set NLS=936
IF %errorlevel%==5 set NLS=950
IF %errorlevel%==6 set /p NLS=请输入语言对应的代码页编号。注意：如果你不明白这里说的是什么，请参阅自述文件。
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

rem 开启 GUI Boot.
:EnableGUI
IF NOT "%EnableGUI%"=="true" goto :Floppy
find /I /N "/noguiboot" %Dir%1\txtsetup.sif>nul|| goto :Floppy
%workplace%EnableGUIBoot.vbs %Dir%1\txtsetup.sif
goto :Floppy

:Missingfile
echo 检测到文件缺失，脚本无法继续。
echo 请更换一个完整的安装文件组，或使用 "/Ignmissingfile" 参数。
echo 有关详细信息，请参阅自述文件。
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
set /p Replace=输入已存放文件的目录以继续。
if not exist %Replace%\CDBOOT1.img (
 echo 此目录不是工作目录。请重试。
 goto :Replace
)
xcopy /Y %workplace%CDBOOTB.img %Replace%\CDBOOT1.img
exit
:error
echo 脚本无法继续，请在解决问题后重试。
:end
del %workplace%%list%>nul
if exist %Missing% echo 缺失文件的名称已输送到 %Missing%。
echo 请按任意键退出。
pause>nul
