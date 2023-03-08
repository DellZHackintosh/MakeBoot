# ![MakeBoot](./makeboot.png)MakeBoot

获得启动软盘所需文件的工具。致敬微软当年提供的启动软盘制作工具。

微软在 Windows NT 5.x 以前提供了软盘启动功能。此工具提供一个替代方案，通过读取相关文件内的信息手动提取所需的文件来制作启动软盘。

### 基本使用方法

只需运行`makebt32.cmd`即可，此工具将自动询问并收集所需信息，然后将对应软盘的文件放置到对应编号的文件夹内。您只需在工具运行完毕后，将提取的文件放入对应的映像文件（也由工具自动准备）即可。

**注意：** 请务必下载本仓库内所有文件！

### 高级使用方法

请键入`makebt32.cmd /?`以获取高级参数。

### 已知问题

- 从 Windows Whistler 开始，某些 Build 会出现软盘空间耗尽了也不足以装下应该装入的文件的情况。您可以尝试把放不下的文件转移到其它尚有空间的软盘并相应修改`txtsetup.sif`，但可能会导致启动软盘的插入顺序变得混乱；而且一些文件间可能存在依存关系，必须在同一个软盘内，此时移动文件会导致此启动软盘不可启动。更好的方法是，尝试通过 MakeBoot 内置的节省空间功能来节省空间，或使用1.68MB的软盘（如果不是含 System32 文件夹的软盘）重试。

- Windows Server 2003 的晚期版本和 Windows Longhorn 全系会出现启动问题：
  ![错误文本：The file i2omp.sys could not be found.](https://wvbimg2-1310561333.cos.ap-tokyo.myqcloud.com/2020-04-05/1586055839-414260-windows-xp-professional-2020-03-14-20-45-44.png)
  这似乎与文件的错误排列导致依存关系被破坏有关。推测为启动软盘不再受支持后，微软可能有意打乱了启动软盘的文件列表，导致了此错误。

- 由于代码过于屎山，此工具提供的极少数参数可能不会正常工作或有瑕疵。非常抱歉😔
  您可以自行修改以解决问题（没有加注释，真的很抱歉😭）。

### 感谢

[BilinSun](https://community.wvbtech.com/u/BilinSun) 的 [bdbuild](https://community.wvbtech.com/d/687) 工具，为此项目提供了很多参考内容。（实际上甚至可以说这是那个工具的重写+额外功能……）

Enjoy it~
