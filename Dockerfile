FROM registry.cn-hangzhou.aliyuncs.com/funasr_repo/funasr:funasr-runtime-sdk-online-cpu-0.1.12

# image installed: FunASR==1.1.12 modelscope==1.19.2
RUN pip install -U  funasr~=1.2 modelscope  Flask && \
 apt update && \
 apt install -y nginx && \
 apt install -y ffmpeg && \
 rm -rf /var/lib/apt

ADD *.sh /workspace/FunASR/runtime/
WORKDIR /workspace/FunASR/runtime
CMD ./start.sh
