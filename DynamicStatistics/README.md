__*注__：

 1 目前只支持通过友盟在线参数配置
   
 2 所有参数都是JSON字符串的形式
 
 3 在线配置服务器（Online Configuration Server以下简称OCS）必须支持多个KeyValue式参数

####根参数配置
######首先在OCS上配置一个根参数，名为statistics_config， 内容格式如下

     {"development”:[“dev_tracker_0"],"production”:[“pro_tracker_0”,”pro_tracker_1"]}  
     
__根参数说明__：参数为字典类型,支持开发/正式环境，客户端必须根据自身运行环境（开发 or 正式）选择对应的tracker列表
     
####tracker参数配置
接下来配置tracker，以dev_tracker_0为例

#####在OCS上配置一个新的在线参数，名为dev_tracker_0，内容格式如下
     
     {"pattern":[pattern0,pattern1],"match_receivers":[{"id":"receiver0"},{"id":"receiver1"}],"accepted_contexts":[“page_appear_context"],"min_supported_version":"0","max_supported_version":"70"}
     这个字典称为一个tracker
     
__tracker参数说明__

___pattern___ 事件匹配模式，类型可以是pattern/patternGroup/patternQueue,客户端应该支持嵌套
	
___match_receivers___ 匹配结果接收方，数组中每一项是一个字典，客户端应该根据数组中的值，选择对应的数据发送策略（必选，至少要有一个客户端支持的receiver，必须包含id）

目前客户端支持四种receiver 

 1. deanxu 将匹配到的events发送到10.1.0.41，该地址上是徐东的电脑在公司AirPort路由器的局域网中的地址，除非用于调试，否则不要用在正式环境中 
 
 2. umeng 将匹配到的events发送到友盟，要求先在友盟设置一个自定义事件，事件id和tracker的id相同
 	- type umeng自定义统计事件的类型，目前支持count和value两种，count代表这是个计数事件，value代表这是个按值分类事件（可选，默认值为count）
 	- event_id umeng自定义统计事件的id（可选，为空则客户端使用tracker的id代替之）
 
 3. track.xiachufang 将匹配到的events发送到track.xiachufang.com，只用于收藏相关的算法优化
 
 4. mma 将匹配到的events通过移动营销联盟SDK发送到相关监测平台，如admaster，秒针等，必须包含action和tracking_url   
	- action mma监测的动作，目前支持view和click（必选）
	- tracking_url mma监测地址，每一个广告位view和click需要的监测地址是不同的，根据action来填充此项参数（必选）
 5. track.xiachufang.common 将匹配到的events发送到track.xiachufang.com，用于一些通用的统计任务
	
___accepted_contexts___ tracker可以接受context被包含在此参数中的event（可选，为空则等同于any匹配所有context）。context为触发event的上下文环境，客户端会填写触发event的接口名，类名，等等任何标明环境信息的数据，客户端目前支持以下几种context： 
 	
 - page_appear_context 页面出现时的上下文
 - page_disappear_context 页面消失时的上下文
 - custom_event_context 客户端旧代码中所有自定义事件的触发都是用这个上下文
 - XcfRecipeCollectionManager iPhone客户端触发收藏时的上下文类名
 - XcfSearchManager iPhone客户端搜索菜谱时的上下文类名
 - XcfApi Android客户端触发收藏和搜索菜谱时的上下文类名
 
___min_supported_version___ tracker支持的最低的客户端版本，格式为整数或符合[语义化版本控制规范](http://semver.org/lang/zh-CN/)

___max_supported_version___ tracker支持的最高的客户端版本，格式同___min_supported_version___
   	
#####pattern内容格式如下
	{"type”:"event_type","actions":[“event_action"],"actions_are_banned":0,"ids":[“event_id"],"identifiers_are_banned":1,"match_quantifier":"{1}"}
	
__pattern参数说明__

___type___ 事件类型，支持的种类由客户端定义，内容类型是字符串（必选），目前支持iPhone项目XcfViewController的所有子类的类名，Android项目BaseActivity的所有子类的类名，recipe，any，旧代码中所有友盟自定义事件的key
      
___actions___ 事件动作，支持的种类由客户端定义，内容类型是字符串数组，（可选，为空则匹配任意值），目前支持appear，disappear，none，any，collect
               
___actions_are_banned___ 代表actions是要禁止的还是接受的，内容类型是布尔值（可选，为空则代表FALSE）
	
___ids___ 事件ID，支持的种类由客户端定义，内容类型是字符串数组（可选，为空则匹配任意值），目前支持菜谱，作品，用户，商品，订单，菜单，话题，讨论区的id
	
___identifiers_are_banned___ 代表ids是要禁止的还是接受的，内容类型是布尔值，（可选，为空则代表FALSE）
	
___match_quantifier___ 匹配符，指明该模式可以匹配多少个连续事件，用法与正则表达式的quantifier相同

#####patternGroup内容格式如下

	{“patterns”:[pattern0,pattern1],”match_quantifier”:{1}}
__patternGroup参数说明__

___patterns___ 组合模式数组，可嵌套，数组内任意pattern匹配成功则表示patternGroup匹配成功，数组内pattern的match_quantifier会被patternGroup自身的match_quantifier覆盖
	
___match_quantifier___ 同pattern


#####patternQueue内容格式如下
	[pattern0,pattern1]
__patternQueue说明__

___patternQueue___只包含一个有序模式数组，可嵌套，数组中pattern按顺序全部匹配成功则表示patternQueue匹配成功，patternQueue的match_quantifier由数组最后一个pattern的match_quantifier决定
	
	
