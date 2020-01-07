# 此处是因为shell脚本文件中不能使用系统中设置的alias
# 需要引入系统设置，然后才能使用
source ~/.bash_profile

#读取用户输入的输入路径（要转换的图片文件夹或图片文件）
read -p "Please input file or directory(请输入要转换的文件或文件夹路径) :" inputPath

#读取用户输入的输出路径（转换成功后的图片文件夹或图片文件）
read -p "Please input output directory(请输入转换后储存的路径) :" outputPath

#读取用户输入的转换质量
read -p "Please input Conversion quality(请输入转换质量) :" qualityNum

function convertFile(){
    # 获取参数：输入路径、输出路径、转换质量
    inDirectory=$1;
    outDirectory=$2;
    quality=$3;

    fileIncludeSuffix=${inDirectory##*/}
    #删除变量 b 右侧第一个出现.的所有字符，并复制给 c
	fileName=${fileIncludeSuffix%.*}

    if [[ ! "$inDirectory" ]]; then
        return 1;
    fi

    output="$outDirectory""/""$fileName"".webp";
    echo "output:"$output;
    
    if [[ -f "$output" ]]; then
        return 2;
    fi
    
    if [[ $quality ]]; then
     
        if [[ $fileIncludeSuffix == *\.gif ]]; then
            gif2webp "$inDirectory" -o "$output" -q "$quality" -lossy -m 6;
        else
            # -quiet,don't print anything
            # -progress,report encoding progress
            # -lossless,有的JPG反而更大！
            # safename="$(echo $input | sed 's# #\\ #g')"
            # 作为参数的时候，带上双引号，这样可以传递有空格的参数！
            cwebp -q "$quality" -quiet -metadata "all" -mt "$inDirectory" -o "$output";
        fi

    else
        cwebp -quiet -metadata "all" -mt "$inDirectory" -o "$output";
    fi
}
# 指定路径的图片转化为webp格式，使用前判断是否是文件！
function convertDirectory(){
    # 获取参数：输入路径、输出路径、转换质量
    inDirectory=$1;
    outDirectory=$2;
    quality=$3;

    # 如果是单个文件的话，执行convertFile
    if [[ -f "$inDirectory" ]]; then
        convertFile "$inDirectory" "$outDirectory" "$quality";
    elif [[ -d "$inDirectory" ]]; then
        echo "convert directory:""$inDirectory""."
        fileList="$inDirectory/*"; 

        for file in $fileList
        do
            if [[ ${file##*.} -ne "webp" ]]; then
                continue;
            fi
            convertDirectory "$file" $outDirectory $quality;
        done
    else
        echo "$inDirectory"" not exist..."
    fi
}

# 如果没有输入文件夹路径，则自动设置为当前目录下边的img文件夹
if [[ ! "$inputPath" ]]; then
    inputPath="$PWD/img";
fi

if [[ ! "$outputPath" ]]; then
    outputPath="$PWD/img";
fi

if [[ ! "$qualityNum" ]]; then
    qualityNum=100;
fi

# echo $inputPath
# echo $outputPath
# echo $qualityNum

# 调用convertDirectory并传参
convertDirectory "$inputPath" "$outputPath" "$qualityNum";