# ====== 模型路径相关参数 ======
download_model_dir="${FUNASR_DOWNLOAD_MODEL_DIR:-/workspace/models}"
model_dir="${FUNASR_MODEL_DIR:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-onnx}"
online_model_dir="${FUNASR_ONLINE_MODEL_DIR:-QuadraV/speech_paraformer-large_asr_nat-zh-cantonese-en-16k-vocab8501-online-onnx}" 
#online_model_dir="${FUNASR_ONLINE_MODEL_DIR:-damo/speech_paraformer-large_asr_nat-zh-cn-16k-common-vocab8404-online-onnx}"
vad_dir="${FUNASR_VAD_DIR:-damo/speech_fsmn_vad_zh-cn-16k-common-onnx}"
punc_dir="${FUNASR_PUNC_DIR:-damo/punc_ct-transformer_zh-cn-common-vad_realtime-vocab272727-onnx}"
itn_dir="${FUNASR_ITN_DIR:-thuduj12/fst_itn_zh}"
lm_dir="${FUNASR_LM_DIR:-damo/speech_ngram_lm_zh-cn-ai-wesp-fst}"

# ====== 网络和连接相关参数 ======
port="${FUNASR_LISTEN_PORT:-10095}"
listen_ip="${FUNASR_LISTEN_IP:-0.0.0.0}"  # 监听地址
certfile="${FUNASR_CERTFILE:-}" # 为空时不启用ssl
# certfile="${FUNASR_CERTFILE:-$(pwd)/ssl_key/server.crt}"
keyfile="${FUNASR_KEYFILE:-$(pwd)/ssl_key/server.key}"
hotword="${FUNASR_HOTWORD:-$(pwd)/websocket/hotwords.txt}"

# ====== 线程和性能相关参数 ======
# set decoder_thread_num
if [ -n "$FUNASR_DECODER_THREAD_NUM" ]; then
  decoder_thread_num=$FUNASR_DECODER_THREAD_NUM
else
  decoder_thread_num=$(cat /proc/cpuinfo | grep "processor"|wc -l) || { echo "Get cpuinfo failed. Set decoder_thread_num = 32"; decoder_thread_num=32; }
fi
multiple_io="${FUNASR_MULTIPLE_IO:-16}"
io_thread_num="${FUNASR_IO_THREAD_NUM:-$(( (decoder_thread_num + multiple_io - 1) / multiple_io ))}"
model_thread_num="${FUNASR_MODEL_THREAD_NUM:-1}"

# ====== 模型版本和加载相关参数 ======
offline_model_revision="${FUNASR_OFFLINE_MODEL_REVISION:-}"  # 离线模型版本
online_model_revision="${FUNASR_ONLINE_MODEL_REVISION:-}"   # 在线模型版本
vad_revision="${FUNASR_VAD_REVISION:-}"            # VAD模型版本
vad_quant="${FUNASR_VAD_QUANT:-true}"           # 是否加载VAD量化模型
punc_revision="${FUNASR_PUNC_REVISION:-}"           # 标点模型版本
punc_quant="${FUNASR_PUNC_QUANT:-true}"          # 是否加载标点量化模型
itn_revision="${FUNASR_ITN_REVISION:-}"            # ITN模型版本
lm_revision="${FUNASR_LM_REVISION:-}"             # 语言模型版本
quantize="${FUNASR_QUANTIZE:-true}"            # 是否加载量化ASR模型

# ====== 解码和搜索相关参数 ======
am_scale="${FUNASR_AM_SCALE:-10.0}"              # 声学模型比例
lattice_beam="${FUNASR_LATTICE_BEAM:-10.0}"          # lattice生成束搜索宽度
global_beam="${FUNASR_GLOBAL_BEAM:-10.0}"           # 解码束搜索宽度
fst_inc_wts="${FUNASR_FST_INC_WTS:-20}"             # 热词权重增益

# ====== 执行路径和命令 ======
cmd_path="${FUNASR_CMD_PATH:-/workspace/FunASR/runtime/websocket/build/bin}"
cmd="${FUNASR_CMD:-funasr-wss-server-2pass}"

#. ./tools/utils/parse_options.sh || exit 1;

if [ -z "$certfile" ] || [ "$certfile" = "0" ]; then
  certfile=""
  keyfile=""
fi

cd $cmd_path

# 初始化命令数组
cmd_args=()

# 添加非空参数到命令数组
[[ -n "$download_model_dir" ]] && cmd_args+=(--download-model-dir "$download_model_dir")
[[ -n "$model_dir" ]] && cmd_args+=(--model-dir "$model_dir")
[[ -n "$online_model_dir" ]] && cmd_args+=(--online-model-dir "$online_model_dir")
[[ -n "$vad_dir" ]] && cmd_args+=(--vad-dir "$vad_dir")
[[ -n "$punc_dir" ]] && cmd_args+=(--punc-dir "$punc_dir")
[[ -n "$itn_dir" ]] && cmd_args+=(--itn-dir "$itn_dir")
[[ -n "$lm_dir" ]] && cmd_args+=(--lm-dir "$lm_dir")
[[ -n "$decoder_thread_num" ]] && cmd_args+=(--decoder-thread-num "$decoder_thread_num")
[[ -n "$model_thread_num" ]] && cmd_args+=(--model-thread-num "$model_thread_num")
[[ -n "$io_thread_num" ]] && cmd_args+=(--io-thread-num "$io_thread_num")
[[ -n "$port" ]] && cmd_args+=(--port "$port")
[[ -n "$listen_ip" ]] && cmd_args+=(--listen-ip "$listen_ip")
[[ -n "$hotword" ]] && cmd_args+=(--hotword "$hotword")
[[ -n "$offline_model_revision" ]] && cmd_args+=(--offline-model-revision "$offline_model_revision")
[[ -n "$online_model_revision" ]] && cmd_args+=(--online-model-revision "$online_model_revision")
[[ -n "$vad_revision" ]] && cmd_args+=(--vad-revision "$vad_revision")
[[ -n "$vad_quant" ]] && cmd_args+=(--vad-quant "$vad_quant")
[[ -n "$punc_revision" ]] && cmd_args+=(--punc-revision "$punc_revision")
[[ -n "$punc_quant" ]] && cmd_args+=(--punc-quant "$punc_quant")
[[ -n "$itn_revision" ]] && cmd_args+=(--itn-revision "$itn_revision")
[[ -n "$lm_revision" ]] && cmd_args+=(--lm-revision "$lm_revision")
[[ -n "$quantize" ]] && cmd_args+=(--quantize "$quantize")
[[ -n "$am_scale" ]] && cmd_args+=(--am-scale "$am_scale")
[[ -n "$lattice_beam" ]] && cmd_args+=(--lattice-beam "$lattice_beam")
[[ -n "$global_beam" ]] && cmd_args+=(--global-beam "$global_beam")
[[ -n "$fst_inc_wts" ]] && cmd_args+=(--fst-inc-wts "$fst_inc_wts")
cmd_args+=(--certfile "$certfile")
cmd_args+=(--keyfile "$keyfile")

echo "${cmd_path}/${cmd}" "${cmd_args[@]}"

# 执行命令
"$cmd_path/$cmd" "${cmd_args[@]}" &

# 构建JSON配置
# 初始化JSON对象
server_cmd_obj="{\"server\":[{\"exec\":\"${cmd_path}/${cmd}\""

# 为每个非空参数添加到JSON
[[ -n "$download_model_dir" ]] && server_cmd_obj+=",\"--download-model-dir\":\"${download_model_dir}\""
[[ -n "$model_dir" ]] && server_cmd_obj+=",\"--model-dir\":\"${model_dir}\""
[[ -n "$online_model_dir" ]] && server_cmd_obj+=",\"--online-model-dir\":\"${online_model_dir}\""
[[ -n "$vad_dir" ]] && server_cmd_obj+=",\"--vad-dir\":\"${vad_dir}\""
[[ -n "$punc_dir" ]] && server_cmd_obj+=",\"--punc-dir\":\"${punc_dir}\""
[[ -n "$itn_dir" ]] && server_cmd_obj+=",\"--itn-dir\":\"${itn_dir}\""
[[ -n "$lm_dir" ]] && server_cmd_obj+=",\"--lm-dir\":\"${lm_dir}\""
[[ -n "$decoder_thread_num" ]] && server_cmd_obj+=",\"--decoder-thread-num\":\"${decoder_thread_num}\""
[[ -n "$model_thread_num" ]] && server_cmd_obj+=",\"--model-thread-num\":\"${model_thread_num}\""
[[ -n "$io_thread_num" ]] && server_cmd_obj+=",\"--io-thread-num\":\"${io_thread_num}\""
[[ -n "$port" ]] && server_cmd_obj+=",\"--port\":\"${port}\""
[[ -n "$listen_ip" ]] && server_cmd_obj+=",\"--listen-ip\":\"${listen_ip}\""
[[ -n "$certfile" ]] && server_cmd_obj+=",\"--certfile\":\"${certfile}\""
[[ -n "$keyfile" ]] && server_cmd_obj+=",\"--keyfile\":\"${keyfile}\""
[[ -n "$hotword" ]] && server_cmd_obj+=",\"--hotword\":\"${hotword}\""
[[ -n "$offline_model_revision" ]] && server_cmd_obj+=",\"--offline-model-revision\":\"${offline_model_revision}\""
[[ -n "$online_model_revision" ]] && server_cmd_obj+=",\"--online-model-revision\":\"${online_model_revision}\""
[[ -n "$vad_revision" ]] && server_cmd_obj+=",\"--vad-revision\":\"${vad_revision}\""
[[ -n "$vad_quant" ]] && server_cmd_obj+=",\"--vad-quant\":\"${vad_quant}\""
[[ -n "$punc_revision" ]] && server_cmd_obj+=",\"--punc-revision\":\"${punc_revision}\""
[[ -n "$punc_quant" ]] && server_cmd_obj+=",\"--punc-quant\":\"${punc_quant}\""
[[ -n "$itn_revision" ]] && server_cmd_obj+=",\"--itn-revision\":\"${itn_revision}\""
[[ -n "$lm_revision" ]] && server_cmd_obj+=",\"--lm-revision\":\"${lm_revision}\""
[[ -n "$quantize" ]] && server_cmd_obj+=",\"--quantize\":\"${quantize}\""
[[ -n "$am_scale" ]] && server_cmd_obj+=",\"--am-scale\":\"${am_scale}\""
[[ -n "$lattice_beam" ]] && server_cmd_obj+=",\"--lattice-beam\":\"${lattice_beam}\""
[[ -n "$global_beam" ]] && server_cmd_obj+=",\"--global-beam\":\"${global_beam}\""
[[ -n "$fst_inc_wts" ]] && server_cmd_obj+=",\"--fst-inc-wts\":\"${fst_inc_wts}\""

# 完成JSON对象
server_cmd_obj+="}]}"

# 保存配置
mkdir -p /workspace/.config
echo "$server_cmd_obj" > /workspace/.config/server_config

