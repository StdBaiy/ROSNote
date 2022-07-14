## 通信机制
- 话题
  - 多个talker和listener
  - 异步，实时性低
  - ROSTCP/ROSUDP
  - 一般用于数据传输
- 服务
  - 单个talker，多个listener
  - 同步，实时性高
  - ROSTCP/ROSUDP
  - 一般用于逻辑处理
- 参数
- 注
  - 统一通过ROS MASTER管理
## 重映射机制
- 把第三方功能包的接口映射到本地接口
## 基本运行流程
1. 创建ws/src
2. 在ws下catkin_make
3. 在src下新建pkg并填上依赖（一般是roscpp、rospy、std_msgs)
4. 改写pkg下的CMakeLists.txt
     - add_executable(节点名  
        src/源文件名.cpp  
      )
     - target_link_libraries(节点名  
        ${catkin_LIBRARIES}  
      )
     - 如果有多个源文件，上面的两段代码要写多次

5. 重新编译
6. 启动roscore
7. 新建终端运行source ./devel/setup.bash
8. rosrun [包名] [节点名]