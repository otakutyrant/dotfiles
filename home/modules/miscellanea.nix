{
  pkgs,
  ...
}:

# Miscellaneous language and speech tools that do not fit the other groups.
with pkgs;
[
  scowl # English words.
  # `openai-whisper` is accurate, but it brings a heavier Python stack and does not support GPU.
  # `whisper-ctranslate2` can be fast, but its Python/CUDA dependency surface is larger.
  # `whisperx` is useful for word timestamps and diarization, but it is overkill for normal SRT files.
  # `whisper-cpp-vulkan` is a useful non-CUDA fallback, but CUDA is better for this NVIDIA machine.
  (whisper-cpp.override {
    cudaSupport = true;
  })
]
