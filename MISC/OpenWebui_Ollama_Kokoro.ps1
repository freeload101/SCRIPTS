# Start the first WSL process hidden
$process1 = Start-Process -FilePath "wsl" -ArgumentList "-d OpenWebUI_WSL_MASTER --exec dbus-launch true" -WindowStyle Hidden -PassThru

# Wait for the first process to start and get its PID
Start-Sleep -Seconds 2  # Adjust the sleep time if necessary
#$pid1 = $process1.Id

# Start the second WSL process hidden, using the PID of the first one
#$dockerArgs = "-d OpenWebUI_WSL_MASTER -u root docker run --gpus all -p 8880:8880 ghcr.io/remsky/kokoro-fastapi-gpu:v0.2.2"
#$process2 = Start-Process -FilePath "wsl" -ArgumentList $dockerArgs -WindowStyle Hidden -PassThru

# Wait for the second process to start and get its PID
#Start-Sleep -Seconds 2  # Adjust the sleep time if necessary
#$pid2 = $process2.Id


$env:OLLAMA_HOST = "0.0.0.0"
# $env:OLLAMA_NUM_PARALLEL = 1
# $env:OLLAMA_MAX_LOADED_MODELS = 3
#$env:OLLAMA_KEEP_ALIVE = "60m"
$env:OLLAMA_KEEP_ALIVE = "-1"
	
	
# Start the third process hidden, using the PIDs of the first two processes (if needed)
Start-Process -FilePath "C:\backup\Ollama\Ollama\ollama.exe" -ArgumentList "serve" -WindowStyle Hidden
