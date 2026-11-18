# Appinn Hidden Profile

一个 Discourse 插件，同时提供用户卡片链接和隐藏资料页面的原生操作。

- 用户卡片提示中的「已被隐藏」链接到该用户的 `/u/:username/profile-hidden`。
- 隐藏资料页面使用 Discourse 原生静音/忽略菜单。
- 补齐访问者自己的关系状态，使官方 Follow 的原生取消关注按钮正常显示。
- 无需额外安装主题组件，不添加重复操作按钮。

卡片使用原生模型中的真实用户名。中文只链接「已被隐藏」，其他语言将整条隐藏提示作为链接。

## 提供的字段

| 字段 | 来源 |
| --- | --- |
| `can_mute_user` | 原生 Guardian 静音权限 |
| `muted` | 当前访问者是否已静音目标 |
| `can_ignore_user` | 原生 Guardian 忽略权限 |
| `ignored` | 当前访问者是否已忽略目标 |
| `can_follow` | 官方 Follow Guardian 权限，未启用 Follow 时为 false |
| `is_followed` | 当前访问者到目标的原始关注关系是否存在 |

只扩展 `HiddenProfileSerializer`。不返回简介、活动、其他关注者或目标用户的隐藏资料，不改变原生权限，不创建或删除关系。没有数据库迁移。

之所以读取原始关注关系，是因为官方 Follow 会从关注列表中过滤隐藏资料或关闭允许关注的目标，即使原始记录仍然存在。缺少列表项不能等同于未关注。

## 安装

将本仓库安装到 Discourse 的 `plugins/appinn-hidden-profile`，然后按实际部署方式重建或重启。Docker 部署通常在 `containers/app.yml` 的插件安装步骤加入：

```yaml
- git clone https://github.com/scavin/appinn-hidden-profile.git
```

这是添加到现有插件安装列表的条目，不是完整部署配置。私有仓库需要部署环境具有读取权限。

插件独立支持原生静音/忽略菜单。关注相关功能需要安装并启用官方 [Discourse Follow](https://github.com/discourse/discourse-follow)。

## 从分离版本迁移

0.2.0 已合并原来的主题组件和状态插件：

1. 在主题后台停用旧的 **Appinn Hidden Profile Actions** 组件。
2. 将部署配置中的旧 `appinn-hidden-profile-state` 插件替换为本仓库，只保留一份安装。
3. 按部署方式重建或重启 Discourse，然后刷新浏览器。

既有忽略、静音和关注关系不需要迁移。旧仓库历史保留，后续只更新本仓库。

## 权限和状态

本次验证的 Follow 版本禁止对开启 `hide_profile` 的用户新增关注，但允许取消已有关系；本插件遵循该判断。

隐藏工作人员的忽略资格仍由原生 Guardian 判断。匿名用户不能取得其他访问者的关系状态。选择原生通知菜单中的「常规」可取消忽略或静音，不提供重复的自建操作按钮。

## 性能和移除

前端监听 DOM 变化更新卡片链接；没有新增接口请求、轮询或后台任务。复用原有隐藏资料响应；登录请求中新增一次使用现有联合索引的关注关系存在性查询，其余字段调用原生 Guardian。未做并发压测。

移除插件并重启可撤回接口扩展，原始关系数据不会被删除。

版本：0.2.0。验证范围见 [TESTING.md](TESTING.md)。

## 自动检查

已接入 [Discourse 官方插件 GitHub Actions](https://github.com/scavin/appinn-hidden-profile/actions/workflows/discourse-plugin.yml)。main 推送、Pull Request 和手动运行都会执行静态检查、后端 RSpec 和前端 QUnit。

CI 通过 `about.json` 安装测试用 Follow 依赖，覆盖隐藏资料权限、访问者状态隔离、保留关注关系和真实用户卡片链接。
