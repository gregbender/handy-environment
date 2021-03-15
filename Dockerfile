FROM registry.access.redhat.com/rhel7/rhel
USER root
ARG S2IDIR="/home/s2i"
ARG APPDIR="/deployments"

LABEL maintainer="Huseyin Akdogan <hakdogan@kodcu.com>" \
      io.k8s.description="S2I builder for Java Applications." \
      io.k8s.display-name="Handy Environment" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,java,maven,gradle" \
      io.openshift.s2i.scripts-url="image://$S2IDIR/bin"

COPY s2i $S2IDIR
RUN chmod 777 -R $S2IDIR

#############################################################################################
# install maven
RUN mkdir /tmp/tools && \
	curl -o /tmp/tools/apache-maven-3.6.3-bin.tar.gz -L https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz && \ 
	tar -zxvf /tmp/tools/apache-maven-3.6.3-bin.tar.gz -C /tmp/tools && \ 
	mkdir /usr/lib/maven && \ 
	mv /tmp/tools/apache-maven-3.6.3/* /usr/lib/maven && \ 
	rm /tmp/tools/apache-maven-3.6.3-bin.tar.gz
ENV PATH="/usr/lib/maven/bin:${PATH}"

# install java
# openj9 java:14

RUN curl -o /tmp/tools/jdk.tar.gz -L https://github.com/AdoptOpenJDK/openjdk15-binaries/releases/download/jdk-15.0.2%2B7_openj9-0.24.0/OpenJDK15U-debugimage_x64_linux_openj9_15.0.2_7_openj9-0.24.0.tar.gz && \ 
	tar -zxvf /tmp/tools/jdk.tar.gz -C /tmp/tools && \ 
	mkdir /usr/lib/jvm && \ 
	mv /tmp/tools/jdk-14.0.2+12/* /usr/lib/jvm && \ 
	rm /tmp/tools/jdk.tar.gz

COPY jdkinstaller.sh "$APPDIR/"
COPY parse_yaml.sh "$APPDIR/"
RUN chmod 777 -R $APPDIR

WORKDIR $APPDIR

EXPOSE 8080

CMD ["$S2IDIR/bin/run"]
