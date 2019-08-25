#docker build -t ccr.ccs.tencentyun.com/dylandocker/myblog:19.09 .
docker run --rm --name myBlog -d -v /Users/lyself/Study/myBlog/tmp:/tmp ccr.ccs.tencentyun.com/dylandocker/myblog:19.09
docker exec myBlog cp -r ./* /tmp
docker stop myBlog