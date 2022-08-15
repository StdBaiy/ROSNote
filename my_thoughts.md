# MY THOUGHTS

## Questions

### 任务是什么？

1. 改写寻路（避障）算法
2. 追加目标追踪模块
3. 集群编队飞行

### 主要难点？

1. 真机移植，会有很多细节问题要处理
2. 搞清楚关键话题，比如地图、速度控制，在此基础上移植
3. 在模拟中，如果能把gazebo的世界直接转化成点云，就可以构建很多复杂的地图用于测试
   - 在网上找到个[开源包](https://github.com/laboshinl/loam_velodyne)，可以转化
4. 目标追踪模块需要安装一大堆驱动
5. siamRPN需要事先手动框选目标，有没有办法避免？
6. siamRPN和YOLO为什么要结合使用？分工是什么
   - 是不是可以用YOLO自动框选出目标，再由siamRPN追踪？
   - 实际上siamRPN的输出和YOLO很类似，但是YOLO会辨认出它识别出的目标，siamRPN则会不断地在周围寻找最初框选的目标

### 一些疑惑

1. local_planner和global_planner的关系是什么？
2. 全局地图更新和局部地图更新有啥区别？
   - 由slam生成的是全局地图，由传感器获取的是局部地图
3. 

## Points

### 已知信息

1. gazebo负责提供模拟数据
2. rviz通过把真实的地图抽象成点云提供可视化（也就是无人机视角里的世界）
3. fast-lab的项目没用到rviz，直接随机生成了点云
4. 寻路算法都要依赖点云进行计算
5. fast-lab的算法在点云的基础上进一步抽象成栅格地图，不过那是算法的实现细节
6. Prometheus的避障算法基本都是定高飞行，fast-lab实现了z轴上的飞行
7. Prometheus的local_planner是一个父类，apf和vfh分别实现了它的compute_force函数，从而实现了不同的规划算法，其中apf简单地把引力和斥力的和作为期望速度
8. 使用YOLO作为目标检测，siamRPN作为目标跟踪
   1. 事先标定相机参数,并提供目标的大致大小,根据目标在镜头中的大小可以估算出距目标的距离
   2. 当连续一段时间无法检测到目标时，认定目标丢失
   3. demo里直接根据距离给出速度了,我们应该加入避障的模块
   4. 由siam_rpn.py发布`/prometheus/object_detection/siamrpn_tracker`话题，并由siamrpn_tracker.cpp接受
