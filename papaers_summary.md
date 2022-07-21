# PAPERS SUMMARY

## Elastic Tracker: A Spatio-temporal Trajectory Planner for Flexible Aerial Tracking

### abstracts

1. 一种遮挡感知的路径搜索方法和一种智能安全飞行走廊(SFC)生成策略。
2. 在不构造 ESDF 的情况下，利用所提出的路径搜索方法的结果对解析遮挡代价进行了评估。
3. 特别设计的配方，以避免遮挡和保持适当的视距。
4. 一种有效的轨迹优化方法能够在保证安全性和可视性的前提下生成时空最优轨迹

### points

- 就好像无人机和目标之间有一个无形的弹簧，既不分开，又可以根据情况灵活伸缩
- 分析遮挡代价评估是顺便的，降低了cost

### related

- G. Chen, W. Dong, X. Sheng, X. Zhu, and H. Ding, “Bio-inspired obstacle avoidance for flying robots with active sensing,” arXiv eprints, pp. arXiv–2010, 2020.
- J. Tordesillas and J. P. How, “Panther: Perception-aware trajectory planner in dynamic environments,” arXiv preprint arXiv:2103.06372, 2021.

## Evolutionary Artificial Potential Fields and Their Application in Real Time Robot Path Planning

### abstracts

新的实时机器人路径规划方法，称为进化人工势场（EAPF）。将人工势场法与遗传算法相结合，得出最优势场函数

### points

1. 在传统的人工势场方法中，障碍物被视为最高势点，目标被视为最低势点。在机器人路径规划领域，机器人总是从高电位点移动到低电位点
2. 在传统的人工势场函数方法中，不涉及优化过程。通过这种方法生成的路径是安全的，但不是最优的
3. 引入额外的“escape force”来解决局部极小值问题
4. 本文所提出的方法始终可以规划最佳的平滑路径，不论障碍物和目标点是静止还是移动

## Modified Artificial Potential Field Method for Online Path Planning Applications

### abstracts

- 改善传统APF的局部极小值问题
- 优点是计算时间较短，符合标准A星（A*）方法
- 根据电位梯度下降算法（PGDA）在电位场中寻找实际路径
- PGDA达到全局最小值时，将仅用一个与机器人最终目标匹配的最小值（全局最小值）构造一个新的势场

### points

- 只要正在进行的状态不同于全局最小值，就执行PGDA。如果它无法前进，陷入局部极小值，那么该算法会向当前状态添加一些额外的排斥势，直到它自由为止
- 这个添加的排斥势可以被保存，用于下一次规划中
