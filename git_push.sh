#!/bin/bash
RED='\e[31m'
GREEN='\e[32m'
END='\e[0m'

recent_file_folder=$(cd $(dirname ${BASH_SOURCE[0]}); pwd )
section=${recent_file_folder##*/}
git_branch=`git symbolic-ref --short -q HEAD | grep '**'` #具体的开发分支，如requirment170914
echo -e $GREEN "尝试推送$section的$git_branch分支\n" $END

##### here define the commit message #####
if [ $# -eq 0 ]
then
    pushmessage=`date -R`
else
    pushmessage="$*"
fi
echo -e $RED $pushmessage $END

# git add *

commit_result=`git commit -m "${pushmessage}"`
# echo -e $commit_result


# 使用双括号防止shell把commit_result理解成多个字符串
if [[ $commit_result =~ "clean" ]]||[[ $commit_result =~ "干净" ]];then
    echo -e "没有新的改动，不需要提交\n"
    exit
elif [[ $commit_result =~ "领先" ]];then
    echo -e 'forward\n'
    # exit
else
    exit
fi

# git push git@github.com:StdBaiy/ROSNote.git
# while [[ $gitpull_results =~ 'remote: Compressing objects: 100%' ]]
