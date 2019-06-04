# Dockerfile   










## 简单Dockerfile 实例  
* node js 

``` docker

FROM  node:9.1.0-alpine 

WORKDIR /src  
COPY express-docker-test /src  

EXPOSE 3000  

RUN  cd /src &&  npm install


CMD npm start

# CMD [ "cd","/src/express-docker-test" ]  
# CMD [ "npm","install" ]  
# CMD [ "npm","start" ]
```

* go  

```docker 
FROM golang:1.9.2-alpine3.6  

MAINTAINER "playtomandjerry"<playtomandjerry@gmail.com>  

EXPOSE 9090  

RUN mkdir /app 

ADD src /app/src
ADD pkg /app
ADD test /app

WORKDIR /app

EXPOSE 9090

# ENTRYPOINT  /app
# WORKDIR /goApp

# COPY  ./ /goApp  

RUN cd /src 

# CMD [ "go","run" "main.go"]
CMD  go run main.go
```
* Java  
    主要针对是Spring Boot 项目


```docker  
FROM java
MAINTAINER "playtomandjerry"<playtomandjerry@gmail.com>

#ADD @project.build.finalName@.jar app.jar

ADD demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8081

CMD java -jar app.jar



```

