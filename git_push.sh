#!/bin/bash
RED='\e[31m'
GREEN='\e[32m'
END='\e[0m\n'

##### here define the commit message #####
if [ $# -eq 0 ]
then
    pushmessage=`date -R`
else
    pushmessage="$*"
fi
echo -e $GREEN $pushmessage $END

git add *

commit_result=`git commit -m "${pushmessage}"`

# 使用双括号防止shell把commit_result理解成多个字符串
if [[ $commit_result =~ "clean" ]]||[[ $commit_result =~ "干净" ]];then
    echo -e $GREEN "无需提交，开始推送到远程仓库..." $END
elif [[ $commit_result =~ "changed" ]];then
    echo -e $GREEN "提交成功，开始推送到远程仓库..." $END
else
    # 异常情况
    echo -e $RED "异常情况，程序退出，具体见commit信息：" $END
    echo -e $commit_result
    exit 1
fi

let n=0
while push_result=`git push origin main`;do
    let n++
    if [ $n -gt 5 ];then
        echo -e $RED "推送失败，请检查配置或者网络" $END
        exit 1
    fi
    # 这里由于git push的返回结果有延迟
    if [[ $push_result =~ "completed" ]];then
        echo -e $GREEN "推送完成" $END
        exit 0
    else
        echo -e $RED "push失败，正在重试($n/5)" $END
    fi
done