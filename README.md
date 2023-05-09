# go-box - A dockerfile for image armourstill/go-box on dockerhub

关于kubeconform工具的使用
-------------------------
- schema缓存
  - 鉴于到github下载schema文件速度过慢，本目录下的`kubeconform-cache`目录中存放了部分k8s版本的schema缓存，目前支持的版本如下
    - 1.21.14-standalone
    - 1.22.12-standalone
    - 1.23.9-standalone
    - 1.24.3-standalone
  - 当制作go-box镜像时，`kubeconform-cache`默认将拷贝至镜像的`/kubeconform-cache`目录
- 容器中推荐的用法` kubeconform -cache /kubeconform-cache -summary -strict -kubernetes-version ${VALID_K8S_VERSION} ${YAML_FILE}`