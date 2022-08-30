# MY THOUGHTS

## Questions

### 任务是什么？

1. 改写寻路（避障）算法
2. 追加目标追踪模块
3. 集群编队飞行
4. 结合目标追踪和避障模块（增设吊舱移动功能）

### 主要难点？

1. 真机移植，会有很多细节问题要处理
2. 搞清楚关键话题，比如地图、速度控制，在此基础上移植
3. 在模拟中，如果能把gazebo的世界直接转化成点云，就可以构建很多复杂的地图用于测试
   - 在网上找到个[开源包](https://github.com/laboshinl/loam_velodyne)，可以转化
4. 结合的难点
   1. 寻路算法会在rviz里给出目标点，也就是说提前知道了全局地图，但是目标追踪似乎不需要全局地图
   2. 
5. 目标追踪模块需要安装一大堆驱动
6. siamRPN需要事先手动框选目标，有没有办法避免？
7. siamRPN和YOLO为什么要结合使用？分工是什么
   - 是不是可以用YOLO自动框选出目标，再由siamRPN追踪？
   - 实际上siamRPN的输出和YOLO很类似，但是YOLO会辨认出它识别出的目标，siamRPN则会不断地在周围寻找最初框选的目标

### 一些疑惑

1. local_planner和global_planner的关系是什么？
2. 全局地图更新和局部地图更新有啥区别？
   - 由slam生成的是全局地图，由传感器获取的是局部地图
3. 源码里面还有一个2D雷达的规划方式，又是什么情况
4. global_planner里面也分为gloabal_point和local_point，二者有什么区别

## Points

### 已知信息

1. gazebo负责提供模拟数据
2. rviz通过把真实的地图抽象成点云提供可视化（也就是无人机视角里的世界）
3. fast-lab的项目没用到rviz，直接随机生成了点云
4. 寻路算法都要依赖点云进行计算
5. fast-lab的算法在点云的基础上进一步抽象成栅格地图，不过那是算法的实现细节
6. Prometheus的避障算法基本都是定高飞行，fast-lab实现了z轴上的飞行
7. Prometheus的local_planner是一个父类，apf和vfh分别实现了它的compute_force函数，从而实现了不同的规划算法，其中apf简单地把引力和斥力的和作为期望速度
8. 在Yolo+SiamRPN中，把YoloV5单独启动为一个Client，通过TCP传递数据，并把数据转为相应的.msg格式，在点击了追踪目标后，无人机将启用SiamRPN追踪该目标
9. 使用YOLO作为目标检测，siamRPN作为目标跟踪
   1. 事先标定相机参数,并提供目标的大致大小,根据目标在镜头中的大小可以估算出距目标的距离
   2. 当连续一段时间无法检测到目标时，认定目标丢失
   3. demo里直接根据距离给出速度了,我们应该加入避障的模块
   4. 由siam_rpn.py发布`/prometheus/object_detection/siamrpn_tracker`话题，并由siamrpn_tracker.cpp接受
10. 摄像头输入的数据会由一个CvBridge的包处理成为cv2格式的图片
11. 话题`/uav/pometheus/state`中的attitude和attitude_q是描述无人机俯仰角和朝向的
12. 有关目标丢失的策略
    1.  ![](images/目标丢失的监测与恢复.jpg)
13. 在论文《基于点云的三维多目标追踪与目标检测算法研究》（DOI:10.27162/d.cnki.gjlin.2022.003464)中提到了根据点云追踪的方法

### 结合策略

- 寻路算法的启动顺序(以local_planner的apf为例)
   1. 启动roscore
   2. 启动map_generator.launch
      1. 启动gazebo world
      2. 启动rviz
      3. 定义集群数量，地图类型
      4. 启动map_generator_node，生成随机地图，并发布全局、局部点云
   3. 启动sitl_px4_indoor.launch
      1. 加载p230模型
      2. 无人机编号，初始位置，航角
      3. 启动mavros
   4. 启动uav_control_main_indoor.launch
      1. 启动uav控制节点
      2. 启动虚拟摇杆驱动
   5. 启动apf算法
      1. 配置算法的具体参数
- 目标检测与追踪算法的启动顺序
   1. 启动yolov5_track_all.launch
      1. 加载gazebo地图，加载p450模型，启动px4
      2. 启动yolov5_tensorrt_client.py
      3. 启动siamrpn_track
      4. 启动yolov5_trt_ros.py
- 尝试先更改地图和模型，使之符合object_detection的功能
- 在siamRPN模块中更改追踪策略，改为发布目标点形式，并调用寻路算法
- 想实现的效果：无人机自动跟随人物运动并避障（可以写一个控制人物模型的脚本，同时使障碍物运动起来，目前的代码需要大改）
- 需不需要写一个点云生成的算法？