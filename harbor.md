wget https://storage.googleapis.com/harbor-releases/release-1.5.0/harbor-online-installer-v1.5.0.tgz

tar xvf harbor-online-installer-v1.5.0.tgz

vi harbor.cfg

./install.sh --with-clair



docker login ns1.tcs-ally.tk

docker tag <image id> ns1.tcs-ally.tk/testocp/prom:v2.2.1

docker push ns1.tcs-ally.tk/testocp/prom:v2.2.1

docker tag <image id> ns1.tcs-ally.tk/testocp/kubewebhook:5.0

docker push ns1.tcs-ally.tk/testocp/kubewebhook:5.0


