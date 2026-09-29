# ci-images

专门存放各项目 CI 用的 Docker 镜像定义，cnb.cool 自己的 `.cnb.yml` pipeline 负责构建 + 推送，
不依赖本地/其他 CI 环境的网络去拉包（这些镜像本身经常要装一堆交叉编译工具链，本地网络
环境不稳定时装包非常痛苦，交给 cnb.cool 自己的 runner 构建更可靠）。

## 结构约定

每个镜像一个 `Dockerfile.<image-name>`，`.cnb.yml` 里对应一组 build/push stage，推送到
`${CNB_DOCKER_REGISTRY}/${CNB_REPO_SLUG_LOWERCASE}/<image-name>:latest`。

新增镜像：加一个 `Dockerfile.<image-name>`，在 `.cnb.yml` 里照抄一组 build/push stage、
把文件名和镜像名换掉。

## 镜像列表

| 镜像 | 用途 | Dockerfile |
|------|------|-----------|
| `dnake-ci-armhf` | dnake 项目 Drone pipeline 交叉编译用：armhf/armel 工具链 + patchelf 预装好，不用每次构建现场 apt install | `Dockerfile.dnake-ci-armhf` |
