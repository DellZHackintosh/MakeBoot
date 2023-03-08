set fso = createobject("scripting.filesystemobject")


' 读取文件
set stream = fso.opentextfile(Wscript.Arguments(0),1)
content = stream.readall()
call stream.close()


' 替换字符串
content = replace(content," /noguiboot","")


' 保存文件
set stream = fso.opentextfile(Wscript.Arguments(0),2)
call stream.write(content)
call stream.close()