### Rmagick
RMagick是Ruby语言跟ImageMagick图形处理程序之间的接口，Ruby程序可以利用RMagick对图像进行缩略、剪裁等等的一系列操作。

#### pdf 转 image 图片模糊

可以通过image 的两个参数来调整：
 > *density*，每英寸内像素点数，越大图片质量越高，默认 75
 > *quality*，图片质量，1-100，越大质量越高

 #### code

``` Ruby
# 当然要使用 rmagick 需要在电脑安装 imagemagick
require 'rmagick'
def 2pdf 
    # 读取当前文件夹中的 pdf 文件
    pdfs=Dir.glob(File.join(Dir.pwd(), "**/*.pdf"))
    # 遍历
    for pdf in pdfs do
        current+=1
        # 获取文件名称（不包含 .pdf 扩展名）
        filename = File.basename(pdf, '.pdf')
        puts "start to convert #{current}/#{total_count}, name: #{filename}"
        # 读取 pdf 文件中的 imageList，并设置图像格式质量等参数
        image_list = Magick::ImageList.new(pdf){|op|
            # 像素密度
            op.density = "200"
            # 质量
            op.quality = 50
            # 格式
            op.format = "jpg"
        }
        # 将图片输出到指定文件夹
        image_list.each_with_index do |image, index|
            puts "current page index #{index+1}..."
            image.write("#{target_path}/#{filename}_#{index+1}.jpg")
        end
    end
end
```

 > imageMagic 官网： [imageMagic](https://imagemagick.org)

 > rmagick doc： [rmagick](https://rmagick.github.io/index.html)

