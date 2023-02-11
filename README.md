# moyu servers.
为实现多开并节省空间使用了多Sourcemod的方法                                 
在addons中：                                                   
sourcemod1:#1 moyu server >> 标准Zonemod服务器，添加了其他很多插件和模式                                  
sourcemod2:#2 moyu server >> 电信Anne服插件.     //因为不方便更新anne插件以及多开sm会有与其他sm共用的内容而导致的冲突，所以决定sm2不使用anne插件了.但是在2.3上传之前的anne服是可以开的，可以看看以前的commit.                            
sourcemod3:#3 moyu server >> 官服经典配置                                             
                     
这三个sm共享同一个addons(意味着三方图也是共享的)和cfg文件夹内以及其他的内容，为区分不同的cvar和相同的cvar不一样的值以及不同的服务器需要加载的插件，分写了多个cfg在里头                                     
                     
# 部分插件来源链接:                         
https://github.com/SirPlease/L4D2-Competitive-Rework - Zonemod主框架                                          
https://github.com/A1oneR/scAvogl - Air编写的清道夫插件，使用其中部分插件替换了Scavogl Rework的部分插件                                              
https://github.com/A1oneR/AirMod - 添加了Air制作过或者在维护的模式                          
https://github.com/fantasylidong/CompetitiveWithAnne - 电信云服Anne插件                     
https://github.com/JoinedSenses/TF2-ServerHop - 用于游戏内查看其他服务器                          
https://github.com/lechuga16/scavogl_rework - Zonemod但是是清道夫                               
https://github.com/draxios/bizzymod - 添加部分写实模式

# To Do-                                   
也许不会to do也许会，我懒想摸鱼  
目前还是有很多bug的 比如比赛模式加载不上之类的 所以还是慎用:)
