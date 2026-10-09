# ci-images

各项目 CI 用的 Docker 镜像定义。GitHub Actions（`.github/workflows/build-images.yml`）
负责构建 **linux/amd64 + linux/arm64** 多平台镜像并推送到 GHCR：

```
ghcr.io/tonyupup/<image-name>:latest
```

CI/k8s 里拉取统一走代理前缀（推送仍是 ghcr.io，代理只用于拉取）：

```
ghcr.dockerproxy.zltop.cn/tonyupup/<image-name>:latest
```

## 目录结构

```
images/
  <image-name>/
    Dockerfile      # 必须；构建上下文就是这个目录
    build.env       # 可选：PLATFORMS=... / BUILD_ARGS=A=1;B=2
    src/            # 可选：需要项目代码时，以 git submodule 挂在这里
scripts/new-image.sh
```

每个镜像一个文件夹，互相隔离；需要项目源码时一律用 submodule 引用，不要拷贝代码进来。

## 新增镜像

```bash
scripts/new-image.sh my-image                                   # 纯工具链镜像
scripts/new-image.sh my-image git@github.com:foo/bar.git main   # 带 submodule 源码
# 编辑 images/my-image/Dockerfile，提交推送即可
```

## 触发规则

| 事件 | 行为 |
|------|------|
| push 到 `main` | 只构建改动过的 `images/<name>/`（含 submodule 指针更新），推送 `latest` + `sha-xxxxxxx` |
| 改了 workflow 或 `.gitmodules` | 全量构建 |
| Pull Request | 只构建不推送 |
| 打 tag `<name>/v1.2.3` | 构建该镜像，额外推送 `1.2.3` |
| Actions 页面手动运行 | 可填镜像名，留空构建全部 |

更新 submodule 后重新构建：`git submodule update --remote images/<name>/src && git commit -am "bump" && git push`。

> 首次推送后，GHCR 包默认是 private；需要匿名拉取的话到 GitHub → Packages → 包设置里改成 public。
> 私有包在 k8s/Drone 里拉取需要配置 `ghcr.io` 的 imagePullSecret（PAT 带 `read:packages`）。

## 镜像列表

| 镜像 | 用途 |
|------|------|
| `dnake-ci-armhf` | dnake 项目 Drone pipeline 交叉编译用：armhf/armel 工具链 + patchelf 预装好 |
| `scanservjs-hplip` | cups-web 的 scanservjs：基于 `sbs20/scanservjs`，预装 `hplip sane-utils`，替代 postStart 里的 apt-get |
| `esphome-gh-builder` | ESPHome 远程构建服务器：实现 Device Builder 的 build-server 协议，把编译转发到 GitHub Actions；以 sidecar 跑在 k8s 的 esphome Deployment 里 |
