# Verification

验证日期：2026-11-18。仅开发环境，不代表生产部署或并发压测。

## 基线

- Discourse：`575d631684b`。
- Discourse Follow：`b6bacc1e2c367207a2661d80b19a3fd2c19137d7`。
- 前身主题组件和状态插件：0.1.1；本仓库合并版本：0.2.0。

## 已完成的真实浏览器/API验证

- 群组成员列表点击隐藏用户，原生用户卡片中的链接进入对应隐藏资料页面。
- 链接使用真实 username，避免误把显示姓名作为用户名。
- 隐藏资料接口返回访问者自己的 `can_ignore_user`、`ignored`、`can_mute_user`、`muted`、`can_follow`、`is_followed`。
- 原生菜单忽略：选择时长、保存后刷新，菜单显示「已忽略」，接口 `ignored=true`。
- 原生菜单选择「常规」：接口 `ignored=false`。
- 原生菜单选择免打扰：刷新后状态保留，接口 `muted=true`。
- 没有额外的自建忽略/关注按钮，保留原生菜单和官方 Follow 入口。
- 隐藏资料时新增关注被官方接口拒绝；公开资料且允许关注时可建立关系。
- 关注后隐藏资料、关闭允许关注，原始关系仍可能保留；配套状态字段能识别该关系，原生取消关注入口可恢复显示。
- 官方取消关注接口可删除上述保留关系；数据库结果已核对。
- 忽略不会自动删除已有关注关系，用户仍可主动取消。
- 低权限、匿名及工作人员的原生权限判断已核对。
- 使用隔离测试账号，清理测试关系，不把测试凭据或环境地址保存到仓库。

## 检查

- 卡片链接前端源文件：Discourse `bin/lint --fix`，ESLint / Prettier 通过。
- 插件源文件：Discourse `bin/lint --fix`，SyntaxTree / RuboCop 通过。
- 导入后的主题字段无编译错误。

## 限制

仓库已接入官方插件 CI；尚未进行完整版本兼容测试或并发压测。原生菜单和 Follow 的交互由对应上游实现承担，后续 Discourse / Follow 升级后需复查。

## 自动化回归测试

- 工作流调用 `discourse/.github/.github/workflows/discourse-plugin.yml@v1`，支持 main 推送、Pull Request 和手动触发。
- 10 个后端请求用例，覆盖权限、忽略/静音状态、访问者隔离、匿名、工作人员、Follow 关闭和保留关系取消关注。本地独立测试数据库运行 10/10 通过。
- 2 个前端验收用例，使用真实用户卡片和 Pretender 夹具，覆盖真实用户名链接、本地化提示及重复打开不重复生成链接。
- 本地 Linux 测试机没有 Chrome，前端自动化由官方 CI 浏览器容器执行；最新远端结果见仓库 Actions 页面。

在完整 Discourse 开发环境可运行：

```sh
LOAD_PLUGINS=1 bin/rspec plugins/appinn-hidden-profile/spec
LOAD_PLUGINS=1 bin/qunit --standalone --target appinn-hidden-profile --filter "Appinn Hidden Profile"
```

## 0.2.0 合并插件验证

- 测试机仅加载 `appinn-hidden-profile`，旧状态插件已移出插件目录备份，旧主题组件已从所有父主题移除。
- 无主题组件的情况下，真实原生用户卡片只生成一个隐藏资料链接，点击进入对应隐藏页面。
- 原生通知菜单保存忽略后刷新，接口 `ignored=true`，页面状态为已忽略。
- 隐藏目标已有关注关系时，接口 `is_followed=true` 且 `can_follow=false`，原生取消关注按钮正常出现。
- 已忽略时点击原生取消关注：关系删除，按钮消失，忽略状态保留。
- 原生菜单选择常规：刷新后 `ignored=false`。
- 验证结束后清理独立测试账号的忽略/静音/关注关系并退出登录。
- 合并未引入数据库迁移，原始关系不需要迁移。

合并插件的独立 `bin/lint --fix` 检查通过：SyntaxTree、RuboCop、Prettier、ESLint。插件附独立开发依赖配置与锁文件。
