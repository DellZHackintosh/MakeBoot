IF NOT "%UseDosnet%"=="true" goto :eof
:loop
set INFDIR=PlaceHolder
set /p INFDIR=输入包含 dosnet.inf 的路径以继续。 

for /F %%C in ("%INFDIR%") DO (
 IF /I not "%%C"=="%INFDIR%" (
  echo 路径存在空格，请输入一个不包含空格的目录路径以重试。
  goto :loop
 )
)

echo %INFDIR% | find /i "dosnet.inf" 1>nul || (
 if not exist %INFDIR%\txtsetup.sif (
  echo 根据您输入的路径，我们刚刚尝试了寻找 %INFDIR%\dosnet.inf。
  echo 但是，按照您输入的路径，我们找不到 dosnet.inf 文件。请确认路径正确后，再试一次。
  goto :loop
 ) else goto :made
)

if not exist %INFDIR% (
 echo 根据您输入的路径，我们刚刚尝试了寻找 %INFDIR%。
 echo 但是，按照您输入的路径，我们找不到 dosnet.inf 文件。请确认路径正确后，再试一次。
 goto :loop
 ) else (
   set INFFile=%INFDIR%
   goto :AC
 )
)
:made
set INFFile=%INFDIR%\dosnet.inf
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
FOR /F "skip=2" %%N in ('find /I /N "disk10" %INFFile%') do (
 set /a disknumber+=1
)
:Next
FOR /L %%n IN (1,1,%disknumber%) DO (
 md %Dir%%%n
 fsutil file createNew %Dir%%%n\DISK10%%n 0
)
:temp
set list=%random%.txt
title %Dir%
cls
echo 我们正在通过 dosnet.inf 创建文件列表。
echo 这只需要不到一分钟的时间，请稍候。
set /A Skip=2
set /A hundred=0
set /A readlines=0
FOR /F %%n in ('find /I /N "[FloppyFiles." %INFFile%^|find /v "x"') do (
 set /a line+=1
)
:work
FOR /F "skip=%Skip% delims=[]" %%i in ('find /I /N "[FloppyFiles." %INFFile%^|find /v "x"') do (
 set Skipline=%%i
 goto :After
)
:After
FOR /F "tokens=3 delims=[]. skip=%Skip%" %%N in ('find /I /N "[FloppyFiles." %INFFile%^|find /v "x"') do (
 set count=%%N
 set /a count+=1
 goto :continue
)
:continue
if /I %readlines%==10 (
 set /A hundred+=1
 set /A readlines=0
 echo 已读取!hundred!0行内容。
)
FOR /F "skip=%Skipline% tokens=1,2,3 delims=," %%A in (%INFFile%) do (
 echo %%A | find "[" > NUL && goto :afterthis
 echo %%C | find "disk10" > NUL && (
  SET /A Skipline+=1
  set /A readlines+=1
  goto :continue
 )
 if /I "%%C"=="" (
  echo %%B#%count%>>%workplace%%list%
 ) else (
  echo %%C#%count%>>%workplace%%list%
 )
 SET /A Skipline+=1
 set /A readlines+=1
 goto :continue
)
:afterthis
set /a skip+=1
IF /I %skip% LSS %line% goto :work
echo 共读取了%hundred%%readlines%行内容。

rem 确保文件没有缺失。
FOR /F %%L in ("%INFFile%") do set FilePath=%%~dpL
IF "%Ignmissingfile%"=="true" goto :IgnoreCheck
rem VIFCheck=Very Important Files（即“非常重要的文件”）.
IF "%IgnAllCheck%"=="true" goto :IgnoreCheck
FOR /F "tokens=1 delims=#" %%F in (%workplace%%list%) do (
 if not exist %FilePath%%%~nF.* goto :Missingfile
)
goto :VIFCheck

:IgnoreCheck
set Missing=MissingFiles-%random%.txt
FOR /F "tokens=1,2 delims=#" %%F in (%workplace%%list%) do (
 if not exist %FilePath%%%~nF.* echo %%F#%%G>>%workplace%..\%Missing%
)
IF "%IgnAllCheck%"=="true" goto :Copy

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

FOR /F "skip=2 tokens=1,2 delims=#" %%M in ('find /I "ntfs.sys" %workplace%%list%') do (
 if exist %Dir%%%N\ntfs.sys (
  makecab /d compressiontype=lzx /d compressionmemory=21 /l %Dir%%%N\ %Dir%%%N\ntfs.sys>>%workplace%..\MakeBoot.log
  del /f /q %Dir%%%N\ntfs.sys>>nul
 )
)
del %workplace%%list%>nul
goto :eof

:Missingfile
echo 检测到文件缺失，脚本无法继续。
echo 请更换一个完整的安装文件组，或使用 "/Ignmissingfile" 参数。
echo 有关详细信息，请参阅自述文件。

