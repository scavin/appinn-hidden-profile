# Appinn Hidden Profile State

Discourse 插件，为隐藏资料接口补充当前访问者自己的关系与权限，让原生用户通知菜单和官方 Follow 按钮正常工作。

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

将本仓库安装到 Discourse 的 `plugins/appinn-hidden-profile-state`，然后按实际部署方式重建或重启。Docker 部署通常在 `containers/app.yml` 的插件安装步骤加入：

```yaml
- git clone https://github.com/scavin/appinn-hidden-profile-state.git
```

这是添加到现有插件安装列表的条目，不是完整部署配置。私有仓库需要部署环境具有读取权限。

插件独立支持原生静音/忽略菜单。关注相关功能需要安装并启用官方 [Discourse Follow](https://github.com/discourse/discourse-follow)。

如果还需要用户卡片中「已被隐藏」的跳转链接，安装配套主题组件 [Appinn Hidden Profile Actions](https://github.com/scavin/appinn-hidden-profile-actions)。

## 权限和状态

本次验证的 Follow 版本禁止对开启 `hide_profile` 的用户新增关注，但允许取消已有关系；本插件遵循该判断。

隐藏工作人员的忽略资格仍由原生 Guardian 判断。匿名用户不能取得其他访问者的关系状态。选择原生通知菜单中的「常规」可取消忽略或静音，不提供重复的自建操作按钮。

## 性能和移除

没有新增接口请求、轮询或后台任务。复用原有隐藏资料响应；登录请求中新增一次使用现有联合索引的关注关系存在性查询，其余字段调用原生 Guardian。未做并发压测。

移除插件并重启可撤回接口扩展，原始关系数据不会被删除。

版本：0.1.1。验证范围见 [TESTING.md](TESTING.md)。
