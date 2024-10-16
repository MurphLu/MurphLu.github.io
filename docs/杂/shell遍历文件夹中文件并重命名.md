### shell 遍历文件件中文件并重命名

```shell
#!/bin/bash
search_rename(){
    # 参数分隔符，默认如果文件或文件夹有空格的话会将其分割处理，需要自定义分隔符，忽略空格
    IFS=$'\t\n'
    # 遍历
    for file in `ls -a "$1"`
    do
        # 拼接路径，用于后续遍历或改名
        source="$1/$file"
        # 如果是文件夹，那么则递归调用
        if [ -d $source ]
        then
            if [[ $file != '.' && $file != '..' ]]
            then
                read_dir $source
            fi
        else # 否则的话常识重命名，此处可以添加更多条件来判断是否进行重命名操作
            echo $source
            # sed 会将管道先传入的字符串根据后面的表达式进行替换
            # s/<source>/<target>/g 不写 g 的话会替换第一个，否则匹配的全部替换
            target=`echo $source | sed 's/test/t_/g'`
            # 目标文件名
            echo "target: $target"
            # 使用 mv 重命名
            mv $source "$target"
        fi
    done
}

#测试目录 test
# 程序入口
search_rename test
```