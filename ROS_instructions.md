# ROS_INSTRUCTIONS

## spin()&spinOnce()

- 出现在消息订阅函数里
- 如果你的程序编写了消息订阅函数，ROS会在程序执行过程中，除了主程序之外，在后台自动接受你指定格式的订阅消息。但是收到的消息不会立即处理，而是必须等到 ros::spin() 或 ros::spinOnce() 执行完毕
- spin()会把主程序阻塞在它的位置，并不断检查有没有新消息，如果有就接受并执行回调函数
- spinOnce()则不会阻塞，如果想要用这个函数监听消息，需要在外面套个循环，并且要考虑到循环的频率（循环过慢且消息队列太短就会漏掉信息）

    ```cpp
    /*...TODO...*/ 
    ros::Rate loop_rate( 100 ); while (ros::ok()) 
    { 
        /*...TODO...*/ 
        user_handle_events_timeout( ... ); 
        ros::spinOnce();                 
        loop_rate.sleep(); 
    }
    ```
