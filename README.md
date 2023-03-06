# moyu servers.
为实现多开并节省空间使用了多Sourcemod的方法(即在启动项加上+sm_basepath addons/sourcemod，指定一个srcds_run的sourcemod地址)                                 
在addons中：                                                   
sourcemod1:#1 moyu server >>                                   
sourcemod2:#2 moyu server >>                    
sourcemod3:#3 moyu server >>                                          
                     
这三个sm在同一个addons下(意味着三方图也是共享的)，除sourcemod之外的所有游戏文件都是共享的.                                  
                     
# 服务器配置                                       
| 标准比赛配置名称 | 配置完善情况 |                                         
|-----------------|--------------|                                            
| ZoneMod v2.8.1/2.8/2.7.1/1.9.3 | √ |                                                
| ZoneHunters v2.8.1/2.8/2.7.1/1.9.3 | √ |                                          
| ZoneMod Retro v2.8.1/2.8/2.7.1 | √ |                                          
| NeoMod v0.4a | √ |                                        
| NextMod v1.0.5 | √ |                                  
| ProMod Elite v1.1 | √ |                                         
| AceMod Revamped v1.2 | √ |                                
| Equilibrium v0.3c | √ |                                         
| Apex v1.1.2 | √ |                                               
                                                              
| 其他比赛模式配置名称 | 配置完善情况 | 是否有自行修复和拓展 |                                                  
|---------------------|-------------|-----------------------|                                               
| Practiceogl Rework(Hunters) v2.2 | √ | √ |                                      
| Scavogl Rework(Chargers/Hunters/Train) v2.2 | √ | √ |                                 
| ProMod v5.0.3 | × | √ |                                             
| ProMod Retro v5.0.3 | × | √ |                               
| ProMod Reflux v5.0.3 | × | √ |                                
| ProMod Hunters(Deadman 1v1) v5.0.3 | × | √ |                          
| ProMod Redtown v5.0.3 | × | √ |                               
| WitchParty(HC) v2.2 | × | √ |                         
| WeiMeng Versus v1.1.0 | √ | × |                                       

| 自改官方模式Vanilla Settings | 配置是否完善 |                                                     
|-----------------------------|--------------|                                          
| Versus | √ |                                  
| Coop | × |                            
| Realism | √ |                             
| Survival | × |                          
| Scavenge | √ |                                        
| Versus Realism | × |                                            
| Versus Survival | × |                 
| Taaannnkk!! | × |                                   
                                          
| 娱乐模式配置 | 配置是否完善 |                         
|--------------|-------------|                                
| AirMod v1.09 | √ |                        
| WTFMod(4v4/3v3/2v2/1v1) v1.6.2 | √ |                      
| Super Survival | × |                                
| Bizzymod 0.8 | × |                                            
| Spacemod -0.8 | × |                                                                            
                                      
| 药役模式配置 | 配置是否完善 |                                     
|--------------|--------------|                                                   
| AnneHappy 2023-1 | × |                                        
| AstMod v2.6.3 | × |                                                             



# 比赛模式来源链接 Matchmode links:                         
https://github.com/SirPlease/L4D2-Competitive-Rework - Zonemod主框架                                          
https://github.com/A1oneR/scAvogl - Air编写的清道夫插件，使用其中部分插件替换了Scavogl Rework的部分插件                                              
https://github.com/A1oneR/AirMod - 添加了Air制作过或者在维护的模式                          
https://github.com/fantasylidong/CompetitiveWithAnne - 电信云服Anne插件                                              
https://github.com/lechuga16/scavogl_rework - Scavogl Rework。zm衍生而来的清道夫插件                               
https://github.com/draxios/bizzymod - 添加部分娱乐写抗模式                                            
https://github.com/mvandorp/server-addons - Promod及其衍生比赛插件包。(注意,该包sm版本过老,拓展插件过老已不可用,需要自己手动修复)                                     
https://github.com/lechuga16/practiceogl_rework - Practiceogl Rework。zm衍生而来的练习插件，自己补充了3v3和4v4和2v2                                                  
https://github.com/Sglight/l4d2-scriptings - AstMod

# 使用过的插件 Plugins used
https://github.com/Silenci0/SMAC - SorceMod Anti Cheat(SMAC)反作弊检测                                                 
https://github.com/J-Tanzanite/Little-Anti-Cheat - Little Anti Cheat(LIAC)反作弊检测
https://github.com/ProdigySim/custom_fakelag - Fakelag plugin                                       
https://github.com/A1oneR/L4D2_DRDK_Plugins - DRDK Plugins                                       
https://github.com/JoinedSenses/TF2-ServerHop - 用于游戏内查看其他服务器                                      
https://github.com/mvandorp/server-plugins - 老promod插件                                     
https://github.com/fbef0102/L4D2-Plugins                                     
https://github.com/fbef0102/L4D1_2-Plugins                                 
https://github.com/Target5150/MoYu_Server_Stupid_Plugins                                     
https://github.com/GlowingTree880/L4D2_LittlePlugins                                          
https://github.com/devilesk/rl4d2l-plugins                                        
https://github.com/rikka0w0/l4d2_mission_manager - ACS自动&投票换图                                                
https://gitee.com/honghl5/open-source-plug-in - Mixmap Credit by BigRed                                            
不能一一列出使用过的插件，但所有插件都是网上收集并部分自行重编译过，感谢所有的插件作者
