#!/bin/bash
# ================================================
# xhs-scout 一键安装脚本
# 用于 OpenClaw Docker 容器内
# ================================================

set -e

echo "🛍️  xhs-scout — 安装中..."
echo ""

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TMP_DIR="/tmp/shopme-mcp-install-$$"
PERSIST_DIR="$HOME/.openclaw/xhs-scout"
SRC_REPO="https://github.com/shopmeskills/mcp.git"

# 清理旧的临时目录
rm -rf "$TMP_DIR"

echo "📦 克隆 Shopme MCP 源码..."
git clone --depth=1 "$SRC_REPO" "$TMP_DIR"

echo "📦 安装依赖..."
cd "$TMP_DIR"
COREPACK_HOME=/tmp/corepack pnpm install --frozen-lockfile

echo "🔨 编译构建..."
COREPACK_HOME=/tmp/corepack pnpm run build

echo "📁 复制到持久化位置 ($PERSIST_DIR)..."
rm -rf "$PERSIST_DIR"
mkdir -p "$PERSIST_DIR"
cp -r "$TMP_DIR/packages/cn-ecommerce-search-mcp/build" "$PERSIST_DIR/build"
cp "$TMP_DIR/packages/cn-ecommerce-search-mcp/package.json" "$PERSIST_DIR/"
cd "$PERSIST_DIR" && npm install --omit=dev --silent

echo "🔧 注册 MCP 服务器..."
openclaw mcp set xhs-scout '{"command":"node","args":["'$PERSIST_DIR'/build/index.js"]}' 2>/dev/null
openclaw mcp reload 2>/dev/null

echo ""
echo "🔍 验证安装..."
if openclaw mcp probe xhs-scout 2>/dev/null | grep -q "3 tools"; then
    echo -e "${GREEN}✅ xhs-scout 安装成功！3 个工具已就绪。${NC}"
else
    echo -e "${RED}⚠️  安装可能有问题，请手动检查 'openclaw mcp probe xhs-scout'${NC}"
fi

echo ""
echo "🎉 现在你可以对 OpenClaw 说："
echo "   '帮我搜一下小红书上有什么好看的帆布包'"
echo ""
echo "📖 完整文档：https://github.com/WangXuexin24/xhs-scout"
