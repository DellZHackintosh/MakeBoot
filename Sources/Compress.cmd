:GetDir
set GetDir=PlaceHolder
set /p GetDir=输入已存放文件的目录以继续。
if not exist %GetDir%\CDBOOT1.img (
 echo 此目录不是工作目录。请重试。
 goto :GetDir
)

:GetNumber
set GetNumber=PlaceHolder
set /p GetNumber=输入需要清理的目录对应的数字。
if not exist %GetDir%\%GetNumber%\ (
 echo 此目录不存在。请重试。
 goto :GetNumber
)

:CleanUp
set Found=0
if exist %GetDir%\%GetNumber%\txtsetup.sif (
 set Found=1
 echo 此目录内的 txtsetup.sif 可压缩！这将不会影响运行。
 CHOICE /M "要压缩此文件吗？"
 if "!errorlevel!"=="1" (
  makecab /d compressiontype=lzx /d compressionmemory=21 /l %GetDir%\%GetNumber%\ %GetDir%\%GetNumber%\txtsetup.sif
  del %GetDir%\%GetNumber%\txtsetup.sif
 )
 if "!errorlevel!"=="2" echo 您已取消压缩此文件。
)

if exist %GetDir%\%GetNumber%\setupreg.hiv (
 set Found=1
 echo 此目录内的 setupreg.hiv 可压缩！这将不会影响运行。
 CHOICE /M "要压缩此文件吗？"
 if "!errorlevel!"=="1" makecab /d compressiontype=lzx /d compressionmemory=21 /l %GetDir%\%GetNumber%\ %GetDir%\%GetNumber%\setupreg.hiv
 if "!errorlevel!"=="2" echo 您已取消压缩此文件。
)

if exist %GetDir%\%GetNumber%\spcmdcon.sys (
 set Found=1
 echo 此目录内的 spcmdcon.sys 可被替换为空文件！除非你需要使用“恢复控制台”功能，否则这将不会影响运行。
 CHOICE /M "要替换此文件吗？"
 if "!errorlevel!"=="1" (
  del %GetDir%\%GetNumber%\spcmdcon.sys
  fsutil file createNew %GetDir%\%GetNumber%\spcmdcon.sys 0
 )
 if "!errorlevel!"=="2" echo 您已取消替换此文件。
)

if exist %GetDir%\%GetNumber%\bootfont.bin (
 set Found=1
 echo 此目录内的 bootfont.bin 可删除！但这将可能导致字符显示错误。
 CHOICE /M "要删除此文件吗？"
 if "!errorlevel!"=="1" del %GetDir%\%GetNumber%\bootfont.bin
 if "!errorlevel!"=="2" echo 您已取消删除此文件。
)

if "%Found%"=="1" (CHOICE /M "本次空间释放已完成。需要再释放其它文件夹吗？") else (CHOICE /M "抱歉，无法释放空间。请使用其它方法处理。需要再释放其它文件夹吗？")
if "!errorlevel!"=="1" goto :GetDir else goto :eof