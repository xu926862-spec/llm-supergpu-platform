# 超级GPU网关 — Windows 直接启动（无需 Docker）
# 需要 Python 3.10+
# 用法: .\start-windows.ps1

param(
    [string]$BailianKey   = $env:BAILIAN_API_KEY,
    [string]$DeepseekKey  = $env:DEEPSEEK_API_KEY,
    [string]$AnthropicKey = $env:ANTHROPIC_API_KEY,
    [string]$MasterKey    = "sk-supergpu",
    [int]$Port            = 4000
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 安装 litellm（如果还没装）
if (-not (Get-Command litellm -ErrorAction SilentlyContinue)) {
    Write-Host "[1/2] 安装 litellm..."
    pip install litellm[proxy] --quiet
}

# 设置环境变量
$env:BAILIAN_API_KEY   = $BailianKey
$env:DEEPSEEK_API_KEY  = $DeepseekKey
$env:ANTHROPIC_API_KEY = $AnthropicKey
$env:LITELLM_MASTER_KEY = $MasterKey

Write-Host "[2/2] 启动超级GPU网关..."
Write-Host ""
Write-Host "  端口:     http://localhost:$Port/v1"
Write-Host "  主密钥:   $MasterKey"
Write-Host "  模型列表: http://localhost:$Port/v1/models"
Write-Host ""
Write-Host "OpenClaw 配置:"
Write-Host "  base_url = http://localhost:$Port/v1"
Write-Host "  api_key  = $MasterKey"
Write-Host "  模型名   = auto / supergpu-fast / supergpu-flagship"
Write-Host ""

litellm --config "$ScriptDir\litellm-config.yaml" --port $Port
