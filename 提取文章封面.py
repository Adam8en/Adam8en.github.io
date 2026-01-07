import os
import re

def get_cover_links(directory):
    cover_links = []

    # 使用os.walk递归遍历所有子文件夹和文件
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):  # 只处理.md文件
                file_path = os.path.join(root, file)
                
                # 打开并读取.md文件的内容
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    
                    # 使用正则表达式提取cover链接
                    match = re.search(r'cover:\s*(https?://[^\s]+)', content)
                    if match:
                        cover_link = match.group(1)

                        # 从链接中提取文件名作为图片名称
                        image_name = cover_link.split('/')[-1].split('.')[0]
                        markdown_format = f'![{image_name}]({cover_link})'
                        cover_links.append(markdown_format)

    return cover_links

# 指定hexo文章目录
hexo_posts_directory = r'D:\\hexo\\source\\_posts'

# 获取所有封面链接
cover_links = get_cover_links(hexo_posts_directory)

# 输出结果
num = 0
for link in cover_links:
    print(link)
    num+=1
print(num)
