# cf-reg

Cloudflare 批量注册工具，自动完成注册、邮箱验证、提取 API Key。

## 安装

```bash
# Unix / macOS / Linux
curl -fsSL https://raw.githubusercontent.com/hefy2027/cf-reg/master/install.sh | bash
```

```powershell
# Windows (PowerShell)
iwr -Uri https://raw.githubusercontent.com/hefy2027/cf-reg/master/install.bat -OutFile install.bat; ./install.bat
```

要求：Node.js >= v20

### 方式二：GitHub Actions 在线运行

无需本地环境，直接在 GitHub 上运行：

1. Fork 本仓库
2. 进入 **Actions** → **Run cf-reg**
3. 点击 **Run workflow**，输入注册数量
4. 运行完成后在 Summary 查看结果

## 使用

```bash
# 注册 5 个账户
cf-reg --count 5

# 无头模式
cf-reg --headless --count 10

# 指定密码
cf-reg --password mypassword --count 3
```

完成后账号信息导出到 `accounts.csv`。

## 参数

| 参数 | 说明 |
|------|------|
| `-c, --count <n>` | 注册数量 |
| `-p, --password <pwd>` | 固定密码 |
| `-r, --random-password` | 随机密码（默认） |
| `--concurrency <n>` | 并发数（默认 3） |
| `--headless` | 无头模式 |
| `--no-headless` | 显示浏览器 |
| `--screenshots` | 启用截图 |
| `-s, --skip-existing` | 跳过已有账户 |
| `--config <path>` | 指定配置文件 |
| `--help` | 查看帮助 |
