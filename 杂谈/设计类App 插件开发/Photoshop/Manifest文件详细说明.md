## 顶级元素 
* `Develop` - 要加载的插件的必填字段。  
* `Publish` - 要在 Adob​​e Developer Console 中提交并在插件管理器中发布的插件的必填字段。


开发/发布

|  名称  | 类型  |  描述   | 必需的  |
|  ---- | ---- |  ----  | ----   |
| manifestVersion  | number | 清单的版本。对于 Photoshop，这应该是4或更高 | 开发/发布 | 
| id | string |插件的唯一标识符。您可以在Adob​​e Developer Console上获取您的唯一 ID  |  开发/发布|
| name | string | 名称应为 3 - 45 个字符。我们建议您的插件名称与您在从 Adob​​e Developer Console 获取插件 ID 时创建的项目名称相匹配。 | 开发/发布| 
| version | string  | 插件的版本号x.y.z格式。版本必须是三个段，每个版本组件必须介于0和之间99。 | 开发/发布 | 
| main | string | 插件初始化代码的路径。这可以是 JavaScript 文件或 HTML 文件。 | 可选（默认为main.js）| 
| icons| IconDefinition[] | 插件的图标（可能在各种上下文中呈现，例如插件面板）支持 PNG、JPG/JPEG 格式，每个图标的最大文件大小为 1MB。您应该至少指定 1x 和 2x 大小。插件管理器的图标直接通过 Adob​​e Developer Console 上传，不包含在您的插件本身中。请参阅我们的“发布您的插件”指南以了解更多信息。 | 发布|
| host | HostDefinition\|HostDefinition[] | 描述可与此插件一起使用的受支持应用程序。这可以包括应用程序的类型、所需的最低版本或插件支持的主机应用程序的最高版本。__注意：数组只能在开发过程中使用。提交到市场时需要一个单一的定义__ | 开发/发布 |
| entryPoints | EntryPointDefinition[] | 描述您的插件添加到插件菜单和插件面板的条目。有关详细信息，请参阅下一节。 | 开发/发布 | 




## icons  
> 图标在开发过程中不是必需的，但__必须在通过插件市场分发时提供__。该`icons`字段是一个`[IconDefinitions]`。  

|  key  | 类型  |  描述   | 
|  ---- | ---- |  ----  | 
| width | number | 逻辑像素宽度 | 
| height | number | 逻辑像素高度 | 
| path | string | 图标的路径（相对于插件根目录） | 
| scale | number[] | 提供的刻度数组。例如，[1, 2]表示有一个@1x和@2x版本的图标指定在path. （可以通过在图标的扩展之前1x添加来指定密度以外的密度）@2x | 
| theme | string[] | 此图标支持的主题数组。Photoshop 支持lightest、light、dark和darkest. 如果所有主题都与图标兼容，则可以使用all. （默认为all）。 | 
| species | string[] | 标识图标的类型以及在哪里显示它是有意义的。默认为generic，这意味着 Photoshop 可以在任何地方自由使用此图标。 |  



## Host 
> HostDefinition此条目允许您的插件指定您的插件可以在哪个应用程序上运行，例如 Adob​​e XD 或 Photoshop. 在开发过程中，该字段可以包含HostDefinition 的数组。这在开发交叉兼容的 UXP 插件时非常方便。但是，在提交到市场期间，只允许一个 HostDefinition。  


|  key  | 类型  |  描述   |  必需的 |
|  ---- | ---- |  ----  |   ----  |  
|  app |  string | 表示此插件支持的应用程序（目前，这里唯一的有效值是"XD"和"PS"）。 |  开发/发布 | 
| minVersion | string |  x.y可以运行此插件的主机应用程序（格式）的最低要求版本。清单 V4 插件的最低有效版本是 version 22.0。注意：版本号必须至少为两段。通常，您会将次要段设置为0，例如22.0。 | 开发/发布 |
| maxVersion | stirng | 以运行此插件的主机应用程序的最大版本。格式与host.minVersion | 可选的 |


## Entry Points
> 是一个 `EntryPointDefinition` 数组。这些条目出现在本机菜单栏中的插件菜单和插件面板中。每个入口点都指定一个`type`, 来指定创建的是直接操作命令或面板显示/隐藏命令。  

|  key  | 类型  |  描述   |      
|  ---- | ---- |  ----  | 
| type | string | 入口点类型：`command`或`panel`。 | 
| id  | stirng  | 入口点的唯一标识符。这id也将映射到插件代码中定义的入口点。 | 
| label | string | 此菜单项的标签，用户将选择它来运行您的插件。可以是单个字符串或本地化字符串的字典。 | 
| shortcut | Object  | 可选的。 定义此菜单项的 Mac 和 Windows 键盘快捷键的对象。有关详细信息，请参阅下面的“键盘快捷键”。仅对command入口点有效。 |
| minimumSize | Object  | 可选的。仅对panel入口点有效。定义面板首选最小尺寸的对象。这个对象的形式{width: number, height: number}是每个长度都以像素为单位。主机应用程序可能不保证最小宽度，具体取决于上下文。 | 
| maximumSize | Object  | 可选的。仅对panel入口点有效。定义面板首选最大尺寸的对象。这个对象的形式{width: number, height: number}是每个长度都以像素为单位。主机应用程序可能无法保证最大宽度，具体取决于上下文。 | 
| preferredDockedSize | Object | 可选的。仅对panel入口点有效。定义停靠时面板首选大小的对象。这个对象的形式{width: number, height: number}是每个长度都以像素为单位。此设置是一种偏好，可能不会被采用。 | 
| preferredFloatingSize | Object  | 可选的。仅对panel入口点有效。定义浮动时面板首选大小的对象。这个对象的形式{width: number, height: number}是每个长度都以像素为单位。此设置是一种偏好，可能不会被采用。 | 
| icons | `array<object>` | 面板的图标。插件中的每个面板都需要自己的一组图标集，最小化时会显示在工具栏中，并且没有提供额外的处理。面板图标的大小为 23x23 (46x46)，并且可以是透明的。这些与主插件中的图标不同。它们在开发过程中是可选的，但如果插件通过开发者控制台提交到插件市场，则它们必须存在于清单和项目中。 | 




## 键盘快捷键(Keyboard shortcuts) 
> 插件的快捷方式尚不可用。  


## 菜单本地化 (Menu Localization)  
> 插件菜单项标签或面板标签可以本地化以匹配主机的当前 UI 语言设置。其他清单字段，例如name 还不能本地化。 本地化标签表示为包含多个翻译的对象，而不是单个字符串值  

__始终需要默认字符串。__  

```json
"label": {
    "default": "Menu Label",
    "fr": "Etiquette de Menu",
    "de": "Menübezeichnung"
}
```
