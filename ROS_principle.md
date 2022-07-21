# ROS PRINCIPLE

## ROS项目的文件结构

- ![文件系统](images/文件系统.jpg)

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

- 可以解决ROS不允许同名节点同时运行的问题
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

## 话题名称

- 话题的名称与节点的命名空间、节点的名称是有一定关系的，话题名称大致可以分为三种类型:（建议通过linux目录系统理解该内容）

1. 全局(话题参考ROS系统，与节点命名空间平级)
2. 相对(话题参考的是节点的命名空间，与节点名称平级)
   - 方便功能包的移植
3. 私有(话题参考节点名称，是节点名称的子级)
   - 仅仅是在namespace层面表示那些资源是私有的，不会与其他的节点产生关系，但是别人依然可以通过路径访问到该资源

- 使用NodeHandle指定了一个namespace之后，该**节点**的所有资源都会相对于该ns
- ROS中的资源包括msg、srv、topic、param

## 名称设置

- ROS的节点、话题重映射、参数设置都可以使用以下三种方式

1. rosrun后面跟参数
2. 卸载launch文件里
3. 代码实现

- 其中参数的设置上，三种方式各有不同
  - rosrun默认设置的是私有参数
  - launch文件，在node标签外的是全局参数，里面的是私有参数

    ```xml
    <launch>

      <param name="p1" value="100" />
      <node pkg="turtlesim" type="turtlesim_node" name="t1">
          <param name="p2" value="100" />
      </node>

    </launch>
    ```

  - 编码实现则是完全自由

    ```cpp
    ros::param::set("/set_A",100); //全局,和命名空间以及节点名称无关
    ros::param::set("set_B",100); //相对,参考命名空间
    ros::param::set("~set_C",100); //私有,参考命名空间与节点名称
    ```

## SLAM

- 全称Simultaneous Localization and Mapping，即时定位与地图构建
- 依赖激光雷达和摄像头等传感器
  - 单目摄像头简单，适用性高，实现较难
  - 双目摄像头可以在静止时测量距离，标定复杂，数据量大
