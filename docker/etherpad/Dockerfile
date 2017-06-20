From centos:centos7
# Enable EPEL for Node.js
#RUN     rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
# Install Node.js and npm
RUN     yum install -y epel-release node
RUN     yum install -y npm git
COPY    installetherpad.sh /usr/local/bin/
RUN     chmod +x /usr/local/bin/installetherpad.sh
RUN     /usr/local/bin/installetherpad.sh
EXPOSE 9001
CMD ["/usr/local/etherpad/etherpad-lite/bin/run.sh", "--root"]
