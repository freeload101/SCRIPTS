# Update package list
sudo apt update

# Install Python pip if not already installed
sudo apt install python3-pip python3-venv -y

# Create and activate virtual environment (recommended)
python3 -m venv whisper-env
source whisper-env/bin/activate

# Install faster-whisper
pip install faster-whisper

------------------- 
# Install NVIDIA CUDA libraries
pip install nvidia-cublas-cu12 nvidia-cudnn-cu12==9.*

# Set the library path (add this to your ~/.bashrc for persistence)
export LD_LIBRARY_PATH=`python3 -c 'import os; import nvidia.cublas.lib; import nvidia.cudnn.lib; print(os.path.dirname(nvidia.cublas.lib.__file__) + ":" + os.path.dirname(nvidia.cudnn.lib.__file__))'`

 