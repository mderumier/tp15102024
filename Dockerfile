
ARG NGINX_VERSION
ARG VOD_MODULE_VERSION
#step 1
FROM centos:centos7
RUN yum groupinstall --disablerepo=\* --enablerepo=base,updates,cr "Development Tools" -y
RUN yum install pcre pcre-devel\
	libxml2 libxml2-devel\
	curl libcurl-devel\
	wget openssl openssl-devel\
	uriparser uriparser-devel\
	diffutils file expat-devel\
	libuuid libuuid-devel -y
#step 2
USER root
RUN mkdir /tmp/nginx /tmp/nginx-vod-module 
RUN curl -Ls -o - https://nginx.org/download/nginx-1.25.3.tar.gz | tar zxf - -C /tmp/nginx --strip-components 1
RUN curl -Ls -o - https://github.com/kaltura/nginx-vod-module/archive/refs/tags/1.33.tar.gz | tar zxf - -C /tmp/nginx-vod-module --strip-components 1
#step 3
WORKDIR /tmp/nginx
RUN ./configure --prefix=/usr/local/nginx --add-module=/tmp/nginx-vod-module --with-http_stub_status_module \
	--with-http_ssl_module --with-file-aio --with-threads --with-cc-opt="-O3"
RUN make -j4 && make install
RUN rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default /app /tmp/nginx /tmp/nginx-vod-module
#step 4
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
