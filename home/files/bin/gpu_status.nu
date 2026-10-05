#!/usr/bin/env nu

# Poll NVIDIA's supported query interface for VRAM usage.
let values = try {
  ^nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits
  | str trim
  | split row ","
  | each { |value| $value | str trim }
} catch {
  print "  󰢮 GPU unavailable"
  exit 0
}

if ($values | length) < 2 {
  print "  󰢮 GPU unavailable"
  exit 0
}

let memory_used = ($values | get 0)
let memory_total = ($values | get 1)
print $"  󰢮 ($memory_used)/($memory_total) MiB"
