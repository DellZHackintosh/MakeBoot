IF NOT "%UseDosnet%"=="true" goto :eof
:loop
set INFDIR=PlaceHolder
set /p INFDIR=������� dosnet.inf ��·���Լ����� 

for /F %%C in ("%INFDIR%") DO (
 IF /I not "%%C"=="%INFDIR%" (
  echo ·�����ڿո�������һ���������ո��Ŀ¼·�������ԡ�
  goto :loop
 )
)

echo %INFDIR% | find /i "dosnet.inf" 1>nul || (
 if not exist %INFDIR%\txtsetup.sif (
  echo �����������·�������Ǹոճ�����Ѱ�� %INFDIR%\dosnet.inf��
  echo ���ǣ������������·���������Ҳ��� dosnet.inf �ļ�����ȷ��·����ȷ������һ�Ρ�
  goto :loop
 ) else goto :made
)

if not exist %INFDIR% (
 echo �����������·�������Ǹոճ�����Ѱ�� %INFDIR%��
 echo ���ǣ������������·���������Ҳ��� dosnet.inf �ļ�����ȷ��·����ȷ������һ�Ρ�
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
echo ��������ͨ�� dosnet.inf �����ļ��б�
echo ��ֻ��Ҫ����һ���ӵ�ʱ�䣬���Ժ�
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
 echo �Ѷ�ȡ!hundred!0�����ݡ�
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
echo ����ȡ��%hundred%%readlines%�����ݡ�

rem ȷ���ļ�û��ȱʧ��
FOR /F %%L in ("%INFFile%") do set FilePath=%%~dpL
IF "%Ignmissingfile%"=="true" goto :IgnoreCheck
rem VIFCheck=Very Important Files�������ǳ���Ҫ���ļ�����.
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

rem ��ʼ�����ļ���
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
echo ��⵽�ļ�ȱʧ���ű��޷�������
echo �����һ�������İ�װ�ļ��飬��ʹ�� "/Ignmissingfile" ������
echo �й���ϸ��Ϣ������������ļ���

