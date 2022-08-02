# SOURCE CODE READING

## Prometheus

### 基本结构

### `Prometheus\Modules\simulator_utils\include\map_generator.cpp`
- 提供了几种基本的地图格式
    ```cpp
    pcl::PointCloud<pcl::PointXYZ> global_map_pcl; // 全局点云地图 - pcl格式
    sensor_msgs::PointCloud2 global_map_ros;       // 全局点云地图 - ros_msg格式
    pcl::PointCloud<pcl::PointXYZ> local_map_pcl;  // 局部点云地图 - pcl格式
    sensor_msgs::PointCloud2 local_map_ros;        // 局部点云地图 - ros_msg格式
    pcl::KdTreeFLANN<pcl::PointXYZ> kdtreeLocalMap;
    ```
- 借助几个基本的图形生成函数(圆柱,直线,方形等)生成随机地图
- 定时发布点云信息（pcl）`/map_generator/local_cloud`
- 点云信息可以被rviz订阅，生成可视化图
- 点云还可以被寻路算法订阅，用于计算轨迹    

### `Prometheus\Modules\simulator_utils\quadrotor_dynamics\quadrotor_dynamics.cpp`

- 记录了无人机的详细参数
    ```c++
    struct State
    {
      Eigen::Vector3d pos;      // 位置
      Eigen::Vector3d vel;      // 速度
      Eigen::Matrix3d R;        // 旋转矩阵
      Eigen::Vector3d omega;    // 角速度
      Eigen::Array4d motor_rpm; // 电机转速
      EIGEN_MAKE_ALIGNED_OPERATOR_NEW;
    };
    ```
- 提供重设这些参数的接口

### `Prometheus\Modules\simulator_utils\include\fake_uav.h`

- 列出了无人机订阅和发布的话题
  ```c++
    // 订阅
    ros::Subscriber pos_cmd_sub;
    ros::Subscriber att_cmd_sub;
    ros::Subscriber ego_cmd_sub;
    ros::Publisher fake_odom_pub;

    // todo 参看estimator
    ros::Publisher uav_state_pub;
    ros::Publisher uav_odom_pub;
    ros::Publisher uav_trajectory_pub;
    ros::Publisher uav_mesh_pub;
    ```

### `Prometheus\Modules\simulator_utils\quadrotor_dynamics\quadrotor_dynamics.cpp`

- 无人机的动力驱动，比较底层

## EGO-PLANNER

### 基本结构
- plan_env：在线映射算法。它以深度图像（或点云）和相机姿态（里程计）对作为输入，进行光线投射以更新概率体积图，并为规划系统构建欧几里德符号距离场 (ESDF)。
- path_searching：前端路径搜索算法。目前它包括一个尊重四旋翼动力学的动力学路径搜索。它还包含一个基于采样的拓扑路径搜索算法，以生成多个拓扑独特的路径，这些路径可以捕捉 3D 环境的结构。
- bspline：基于 B 样条的轨迹表示的实现。
- bspline_opt：使用 B 样条轨迹的基于梯度的轨迹优化。
- active_perception：感知感知规划策略，使四旋翼能够主动观察并避开未知障碍物，在未来出现。
- plan_manage：调度和调用映射和规划算法的高级模块。这里包含启动整个系统的接口以及配置文件。
- 除了文件夹fast_planner，一个轻量级的uav_simulator用于测试。

### `ego-planner\src\planner\path_searching\src\dyn_a_star.cpp`

- 动态A\*寻路算法,又称D\*算法

  ```text
  初始化open_set和close_set；
  将起点加入open_set中，并设置优先级为0（优先级最高）；
  如果open_set不为空，则从open_set中选取优先级最高的节点n：
      如果节点n为终点，则：
          从终点开始逐步追踪parent节点，一直达到起点；
          返回找到的结果路径，算法结束；
      如果节点n不是终点，则：
          将节点n从open_set中删除，并加入close_set中；
          遍历节点n所有的邻近节点：
              如果邻近节点m在close_set中，则：
                  跳过，选取下一个邻近节点
              如果邻近节点m也不在open_set中，则：
                  设置节点m的parent为节点n
                  计算节点m的优先级
                  将节点m加入open_set中
    ```

- GridNodePtr

    ```cpp
    typedef GridNode *GridNodePtr;

    struct GridNode
    {
        enum enum_state
        {
            OPENSET = 1,
            CLOSEDSET = 2,
            UNDEFINED = 3
        };

        int rounds{0}; // Distinguish every call
        enum enum_state state
        {
            UNDEFINED
        };
        Eigen::Vector3i index;

        double gScore{inf}, fScore{inf};
        GridNodePtr cameFrom{NULL};
    };
    ```

  - ebum_state是地图点的三种类型，open代表可以走，closed代表不能走,undefined是D\*算法相比A\*多出来的部分，无人机边观察变填充地图数据
  - gScore是根据节点n距离起点的代价
  - fScore是节点n的综合优先级。当我们选择下一个要遍历的节点时，我们总会选取综合优先级最高（值最小）的节点
  - rounds用来区分每次调用?

- neighborPtr

- Eigen

### `ego-planner\src\planner\plan_env\src\grid_map.cpp`

- 空白

### `ego-planner\src\planner\plan_manage\src\ego_replan_fsm.cpp`

```c++
void execFSMCallback(const ros::TimerEvent &e);
```

- 实现了一个状态机，无人机始终在***起始、等待航点、规划路线、重新规划路线、执行路线、紧急停止***这几个状态间切换
- ![](images/UAV_status.jpg)

```c++
void EGOReplanFSM::checkCollisionCallback(const ros::TimerEvent &e);
```

- 总是根据当前轨迹继续规划,如果检测到碰撞就重新规划
- 规划失败的时候说明周围有障碍物,检测是否需要急停

```c++
bool EGOReplanFSM::callReboundReplan(bool flag_use_poly_init, bool flag_randomPolyTraj)
```

- 弹性规划，两个参数的具体含义不明，推测是跟轨迹随机初始化有关
- 轨迹规划的具体实现在planner_manage.cpp中
- 改变接收到的B样条数据格式并发布
  
```c++
bool planFromCurrentTraj();
```

- 沿当前路径规划，仅在周围没有障碍物的时候调用
- 会依次尝试调用callReboundReplan(false,false),(true,false),(true,true)全部失败才返回false

### `ego-planner\src\planner\plan_manage\src\planner_manager.cpp`

- 紧急停止函数就是简单地把轨迹的控制点全都设为同一个点
- 用到了Eigen库，大量使用了其中的Vector3d（也即三维向量）表示点、速度、加速度等，用它方便地计算了两个点的距离
- 本函数库与polynomial_traj.cpp以及plan_env/高度相关，只能读懂大概意思