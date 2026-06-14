# 🛍️ xhs-scout

[**简体中文**](README.md) · [English](README_en.md)

> 小红书 + 淘宝 + 天猫商品搜索 MCP 服务器 | Chinese E-commerce Product Search for AI Agents

[![Vibecoding](https://img.shields.io/badge/🤖-Vibecoded_by_Clio-purple)](#⚠️-vibecoding-声明)
[![Powered by Shopme](https://img.shields.io/badge/Powered_by-Shopme-orange)](https://github.com/shopmeskills/mcp)
[![Platform](https://img.shields.io/badge/Platform-OpenClaw-blue)](https://openclaw.ai)
[![License](https://img.shields.io/badge/License-MIT-green)](https://github.com/shopmeskills/mcp/blob/main/LICENSE)

让 AI 助手直接搜索小红书、淘宝、天猫的商品 — 无需 API Key，开箱即用。

## 🎯 这是什么

**xhs-scout** 是一个为 [OpenClaw](https://openclaw.ai) 优化的 MCP (Model Context Protocol) 服务器，让 AI 能够直接搜索和查询中文电商平台的商品信息。

你只需要对 AI 说「帮我搜一下小红书上有什么好看的帆布包」，它就能返回真实的商品数据（名称、价格、销量、图片）。

## ✨ 功能

| 工具 | 说明 |
|------|------|
| `search_products` | 关键词搜索商品，支持按平台/价格/销量/相关性排序 |
| `get_product_detail` | 获取商品完整详情（名称、价格、图片、SKU、店铺等） |
| `parse_product_link` | 解析商品链接，识别平台和商品 ID |

## 📦 支持的平台

| 平台 | 搜索 | 详情 | 链接解析 |
|------|:----:|:----:|:----:|
| 🟢 小红书 (XHS) | ✅ 稳定 | ✅ 稳定 | ✅ |
| 🟡 淘宝 (Taobao) | ⚠️ 偶尔可用 | ✅ | ✅ |
| 🔴 天猫 (Tmall) | ⚠️ 不稳定 | ✅ | ✅ |
| ⚫ 京东/拼多多/1688/抖音 | ❌ 不可用 | ❌ | ⚠️ 部分支持 |

> ⚠️ **重要声明：以上实测基于 2026-06-14，由 OpenClaw + xhs-scout 在 Telegram 中实际调用测试。**
> 
> - 🟢 **小红书（XHS）**：唯一经过充分测试且稳定可用的平台
> - 🟡 **淘宝/天猫**：不稳定，偶尔返回结果，搜索功能不可靠
> - ⚫ **京东/拼多多/1688/抖音/速卖通**：未测试，MCP 声称支持但实际均未验证
>
> Shopme API 后端由第三方维护，可用性可能随时变化。**不要在生产环境依赖非 XHS 平台的搜索功能。**

## 🚀 安装

### 前置条件

- [OpenClaw](https://openclaw.ai) 已部署
- 无需任何 API Key

### 方式一：使用预编译的 MCP 服务器（推荐）

```bash
# 进入你的 OpenClaw 容器
docker exec -it openclaw-gateway bash

# 克隆仓库
git clone https://github.com/shopmeskills/mcp.git /tmp/shopme-mcp
cd /tmp/shopme-mcp

# 安装依赖并构建（需要 pnpm）
COREPACK_HOME=/tmp/corepack pnpm install
COREPACK_HOME=/tmp/corepack pnpm run build

# 复制到持久化位置（防止容器重启丢失）
mkdir -p ~/.openclaw/xhs-scout
cp -r packages/cn-ecommerce-search-mcp/build ~/.openclaw/xhs-scout/build
cp packages/cn-ecommerce-search-mcp/package.json ~/.openclaw/xhs-scout/
cd ~/.openclaw/xhs-scout && npm install --omit=dev

# 注册 MCP 服务器
openclaw mcp set xhs-scout '{"command":"node","args":["/home/node/.openclaw/xhs-scout/build/index.js"]}'
openclaw mcp reload
openclaw mcp probe xhs-scout  # 应该显示 "3 tools"
```

### 方式二：一键安装脚本

```bash
# 仍在容器内
curl -fsSL https://raw.githubusercontent.com/WangXuexin24/xhs-scout/main/install.sh | bash
```

## 💬 使用示例

### 搜索商品

```
你：帮我搜一下小红书上有什么好用的机械键盘

AI 调用 search_products(keyword="机械键盘", platform="xhs", limit=5)
→ 返回商品列表：名称、价格、销量、图片、店铺
```

### 查看详情

```
你：看看这个商品的详情

AI 调用 get_product_detail(product_id="65979cf6fe176f00011f9bd9", platform="xhs")
→ 返回完整信息：描述、SKU 规格、标签、预计重量
```

### 解析链接

```
你：这个是哪个平台的？

AI 调用 parse_product_link(url="https://item.taobao.com/item.htm?id=12345678")
→ 返回：{ platform: "taobao", productId: "12345678" }
```

### 实际搜索效果

```
> 搜索"有线耳机" on 小红书
→ 找到 17 个商品
→ 热门推荐：水月雨竹2 DSP ¥129、威捷娜 ¥12.2~
→ 直接返回商品名称、销量、价格、图片链接
```

## 🔧 工具参数说明

### search_products

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|:----:|--------|------|
| `keyword` | string | ✅ | - | 搜索关键词（中英文均可） |
| `platform` | enum | ❌ | 全部 | `xhs` / `taobao` / `tmall` |
| `sort_by` | enum | ❌ | `relevance` | `relevance` / `price_asc` / `price_desc` / `sales_desc` |
| `page` | number | ❌ | `1` | 页码 |
| `limit` | number | ❌ | `10` | 每页数量（最大 50） |

### get_product_detail

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `product_id` | string | 二选一 | 商品 ID（推荐优先使用） |
| `url` | string | 二选一 | 商品链接 |
| `platform` | enum | ❌ | 建议提供以加速查询 |

### parse_product_link

| 参数 | 类型 | 必填 | 说明 |
|------|------|:----:|------|
| `url` | string | ✅ | 商品链接或包含链接的文本 |

## 🏗️ 架构

```
你 → OpenClaw → xhs-scout (MCP Server) → Shopme API → 小红书/淘宝/天猫
```

- **MCP 服务器**：[shopmeskills/mcp](https://github.com/shopmeskills/mcp) — 原始代码，TypeScript 编写
- **数据源**：Shopme 统一商品数据库（`api.shopmeagent.com`）
- **协议**：Model Context Protocol (MCP) stdio 传输

## ⚖️ 法律声明

- 本工具通过 **Shopme 公开 API**（`api.shopmeagent.com`）查询数据，不直接爬取任何平台
- 展示的所有商品信息均来自平台的公开数据
- 本仓库仅包含配置文件和文档，不含任何平台专有数据
- 如果您是平台方并对此工具有疑虑，请 [提交 Issue](https://github.com/WangXuexin24/xhs-scout/issues)

## 📸 截图

### 1. 在 Telegram 中搜索商品

![搜索效果](screenshots/search-results.jpg)

> 对 OpenClaw 说「在小红书搜帆布包」，返回商品图片、名称、价格和销量。

### 2. 返回商品链接

![商品链接](screenshots/product-links.jpg)

> AI 同时返回商品的完整列表和链接，可按销量/价格排序。

### 3. 在小红书客户端验证

![小红书验证](screenshots/xiaohongshu-verify.jpg)

> 点击链接可跳转到小红书 App/网页，确认商品真实存在。

## ⚠️ Vibecoding 声明

**这个仓库是 AI（Clio）编写的，没有经过人类代码审查。**

- 🧠 代码由 AI assistant 自动生成和部署
- 🎯 目标是"能用"，不是"完美"
- ⚠️ 不适合生产环境，AI 可能会犯错
- 🙏 如果你发现了 bug，欢迎提 Issue 或 PR
- 💡 如果你喜欢这个工具并获得了帮助，请给个 Star ⭐

## 🙏 致谢

本工具的 MCP 服务器核心代码来自 **[shopmeskills/mcp](https://github.com/shopmeskills/mcp)**，由 Shopme 团队开发维护。

- 原作者：[@shopmeskills](https://github.com/shopmeskills)
- 原始仓库：https://github.com/shopmeskills/mcp
- 使用的包：`packages/cn-ecommerce-search-mcp`

**xhs-scout 只是对 Shopme MCP 服务器的封装和文档化，方便 OpenClaw 用户开箱即用。**  
数据来源于 Shopme API，版权归各电商平台所有。

## 📖 English Version

👉 [README_en.md](README_en.md)

## 📗 其他平台说明

虽然 MCP 底层声称支持 8 个平台，但**实际测试仅有小红书（XHS）可用**：

- 淘宝搜索不稳定（仅部分英文关键词偶尔有结果）
- 天猫/京东/拼多多/1688/抖音/速卖通：搜索基本不返回结果
- 链接解析功能对主要平台均可用（即使搜索不可用）

**如果你在这些平台上搜索不到结果，不是你的配置问题——是上游 API 的限制。** 欢迎提交 PR 改进。

## 📄 许可证

本项目的安装脚本和文档采用 MIT 许可证。  
MCP 服务器核心代码的许可证参见 [shopmeskills/mcp](https://github.com/shopmeskills/mcp)。

---

💬 有问题？[提交 Issue](https://github.com/WangXuexin24/xhs-scout/issues) · 觉得有用？给个 ⭐ Star
