:GetDir
set GetDir=PlaceHolder
set /p GetDir=�����Ѵ���ļ���Ŀ¼�Լ�����
if not exist %GetDir%\CDBOOT1.img (
 echo ��Ŀ¼���ǹ���Ŀ¼�������ԡ�
 goto :GetDir
)

:GetNumber
set GetNumber=PlaceHolder
set /p GetNumber=������Ҫ�����Ŀ¼��Ӧ�����֡�
if not exist %GetDir%\%GetNumber%\ (
 echo ��Ŀ¼�����ڡ������ԡ�
 goto :GetNumber
)

:CleanUp
set Found=0
if exist %GetDir%\%GetNumber%\txtsetup.sif (
 set Found=1
 echo ��Ŀ¼�ڵ� txtsetup.sif ��ѹ�����⽫����Ӱ�����С�
 CHOICE /M "Ҫѹ�����ļ���"
 if "!errorlevel!"=="1" (
  makecab /d compressiontype=lzx /d compressionmemory=21 /l %GetDir%\%GetNumber%\ %GetDir%\%GetNumber%\txtsetup.sif
  del %GetDir%\%GetNumber%\txtsetup.sif
 )
 if "!errorlevel!"=="2" echo ����ȡ��ѹ�����ļ���
)

if exist %GetDir%\%GetNumber%\setupreg.hiv (
 set Found=1
 echo ��Ŀ¼�ڵ� setupreg.hiv ��ѹ�����⽫����Ӱ�����С�
 CHOICE /M "Ҫѹ�����ļ���"
 if "!errorlevel!"=="1" makecab /d compressiontype=lzx /d compressionmemory=21 /l %GetDir%\%GetNumber%\ %GetDir%\%GetNumber%\setupreg.hiv
 if "!errorlevel!"=="2" echo ����ȡ��ѹ�����ļ���
)

if exist %GetDir%\%GetNumber%\spcmdcon.sys (
 set Found=1
 echo ��Ŀ¼�ڵ� spcmdcon.sys �ɱ��滻Ϊ���ļ�����������Ҫʹ�á��ָ�����̨�����ܣ������⽫����Ӱ�����С�
 CHOICE /M "Ҫ�滻���ļ���"
 if "!errorlevel!"=="1" (
  del %GetDir%\%GetNumber%\spcmdcon.sys
  fsutil file createNew %GetDir%\%GetNumber%\spcmdcon.sys 0
 )
 if "!errorlevel!"=="2" echo ����ȡ���滻���ļ���
)

if exist %GetDir%\%GetNumber%\bootfont.bin (
 set Found=1
 echo ��Ŀ¼�ڵ� bootfont.bin ��ɾ�������⽫���ܵ����ַ���ʾ����
 CHOICE /M "Ҫɾ�����ļ���"
 if "!errorlevel!"=="1" del %GetDir%\%GetNumber%\bootfont.bin
 if "!errorlevel!"=="2" echo ����ȡ��ɾ�����ļ���
)

if "%Found%"=="1" (CHOICE /M "���οռ��ͷ�����ɡ���Ҫ���ͷ������ļ�����") else (CHOICE /M "��Ǹ���޷��ͷſռ䡣��ʹ����������������Ҫ���ͷ������ļ�����")
if "!errorlevel!"=="1" goto :GetDir else goto :eof