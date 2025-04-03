# FunASR WebSocket 服务器启动脚本使用指南

该文档介绍了如何使用 FunASR WebSocket 服务启动脚本。FunASR 是一个功能强大的语音识别框架，通过 WebSocket 服务可以提供实时语音识别功能。

## 功能概述

该脚本用于启动 FunASR WebSocket 服务器，支持：

- 离线和在线语音识别模式
- VAD（语音活动检测）
- 标点符号恢复
- ITN（逆文本归一化）
- 语言模型整合
- 热词识别优化

## 使用方法

### 基本用法

```bash
bash run_server_2pass_env.sh
```

这将使用默认配置启动 FunASR WebSocket 服务器。

### 通过环境变量配置

所有参数都可以通过环境变量进行配置，格式为 `FUNASR_参数名`，例如：

```bash
export FUNASR_LISTEN_PORT=12345
export FUNASR_MODEL_DIR="my/custom/model"
bash run_server_2pass_env.sh
```

## 支持的参数

### 模型路径相关参数

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_DOWNLOAD_MODEL_DIR | /workspace/models | 从 ModelScope 下载模型的保存路径 |
| FUNASR_MODEL_DIR | damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-onnx | ASR 模型路径。其他：<br> * iic/SenseVoiceSmall-onnx 、 <br> * damo/speech_paraformer-large-vad-punc_asr_nat-zh-cn-16k-common-vocab8404-onnx（时间戳）、  <br> * damo/speech_paraformer-large-contextual_asr_nat-zh-cn-16k-common-vocab8404-onnx（nn热词） |
| FUNASR_ONLINE_MODEL_DIR | damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx | 在线 ASR 模型路径。  <br>  其他：QuadraV/speech_paraformer-large_asr_nat-zh-cantonese-en-16k-vocab8501-online-onnx |
| FUNASR_VAD_DIR | damo/speech_fsmn_vad_zh-cn-16k-common-onnx | VAD 模型路径 |
| FUNASR_PUNC_DIR | damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx | 标点模型路径 |
| FUNASR_ITN_DIR | thuduj12/fst_itn_zh | ITN 模型路径 |
| FUNASR_LM_DIR | damo/speech_ngram_lm_zh-cn-ai-wesp-fst | 语言模型路径 |

### 网络和连接相关参数

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_LISTEN_PORT | 10095 | 监听端口 |
| FUNASR_LISTEN_IP | 0.0.0.0 | 监听地址 |
| FUNASR_CERTFILE | $(pwd)/ssl_key/server.crt | WSS 连接的证书文件路径 |
| FUNASR_KEYFILE | $(pwd)/ssl_key/server.key | WSS 连接的密钥文件路径 |
| FUNASR_HOTWORD | $(pwd)/websocket/hotwords.txt | 热词文件路径 |

### 线程和性能相关参数

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_DECODER_THREAD_NUM | CPU核心数 | 解码线程数 |
| FUNASR_MULTIPLE_IO | 16 | IO 倍数 |
| FUNASR_IO_THREAD_NUM | (decoder_thread_num + multiple_io - 1) / multiple_io | IO 线程数 |
| FUNASR_MODEL_THREAD_NUM | 1 | 模型线程数 |

### 模型版本和加载相关参数

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_OFFLINE_MODEL_REVISION | master | 离线模型版本 |
| FUNASR_ONLINE_MODEL_REVISION | master | 在线模型版本 |
| FUNASR_VAD_REVISION | - | VAD 模型版本 |
| FUNASR_VAD_QUANT | true | 是否加载 VAD 量化模型 |
| FUNASR_PUNC_REVISION | - | 标点模型版本 |
| FUNASR_PUNC_QUANT | true | 是否加载标点量化模型 |
| FUNASR_ITN_REVISION | - | ITN 模型版本 |
| FUNASR_LM_REVISION | - | 语言模型版本 |
| FUNASR_QUANTIZE | true | 是否加载量化 ASR 模型 |

### 解码和搜索相关参数

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_AM_SCALE | 10.0 | 声学模型比例 |
| FUNASR_LATTICE_BEAM | 10.0 | lattice 生成束搜索宽度 |
| FUNASR_GLOBAL_BEAM | 10.0 | 解码束搜索宽度 |
| FUNASR_FST_INC_WTS | 20 | 热词权重增益 |

### 执行路径和命令

| 环境变量 | 默认值 | 说明 |
|----------|--------|------|
| FUNASR_CMD_PATH | /workspace/FunASR/runtime/websocket/build/bin | 命令路径 |
| FUNASR_CMD | funasr-wss-server-2pass | 执行命令 |

## 热词配置

热词文件格式为每行一个热词和权重，例如：

```
阿里巴巴 20
达摩院 15
```

## SSL 配置

如果需要启用 WSS (WebSocket Secure)，请确保提供有效的证书和密钥文件。如果 `FUNASR_CERTFILE` 为空或设为 0，则服务将使用普通 WebSocket 模式。

## 示例

### 启动基本服务

```bash
bash run_server_2pass_env.sh
```

### 自定义端口和模型

```bash
export FUNASR_PORT=12345
export FUNASR_MODEL_DIR="custom/asr/model/path"
export FUNASR_VAD_DIR="custom/vad/model/path"
bash run_server_2pass_env.sh
```

### 调整性能参数

```bash
export FUNASR_DECODER_THREAD_NUM=16
export FUNASR_MODEL_THREAD_NUM=4
export FUNASR_MULTIPLE_IO=8
bash run_server_2pass_env.sh
```

### 使用非量化模型

```bash
export FUNASR_QUANTIZE=false
export FUNASR_VAD_QUANT=false
export FUNASR_PUNC_QUANT=false
bash run_server_2pass_env.sh
```

## 服务配置保存

脚本会自动将服务配置保存到 `/workspace/.config/server_config` 文件中，以 JSON 格式存储所有参数。

## 故障排除

1. 确保所有指定的目录和文件路径存在
2. 检查端口是否被其他应用占用
3. 检查模型路径是否正确
4. 确保有足够的系统资源（内存、CPU）运行服务

如需更多帮助，请参考 FunASR 官方文档和支持渠道。
