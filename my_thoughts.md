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
