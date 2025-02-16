# Google Cloud
$env.CLOUDSDK_PYTHON = '/usr/bin/python'
$env.CLOUDSDK_PYTHON_ARGS = '-S -W ignore'
$env.CLOUDSDK_ROOT_DIR = '/opt/google-cloud-cli'
$env.GOOGLE_CLOUD_SDK_HOME = '/opt/google-cloud-cli'
let GOOGLE_CLOUD_CLI_PATH = ( $env.GOOGLE_CLOUD_SDK_HOME | path join bin )
$env.PATH = ( $env.PATH | prepend $GOOGLE_CLOUD_CLI_PATH )

# CUDA
$env.CUDA_PATH = '/opt/cuda'
let $CUDA_BIN_PATH = ( $env.CUDA_PATH | path join bin )
$env.PATH = ( $env.PATH | prepend $CUDA_BIN_PATH )
