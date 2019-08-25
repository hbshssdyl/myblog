docker stop myBlog
docker rm myBlog
# docker run --name myBlog -v "$(pwd):/myBlog" -d -p 4000:4000 myblog
docker run --name myBlog -v "$(pwd)":/myBlog -d -p 80:4000 ccr.ccs.tencentyun.com/dylandocker/myblog:19.09
