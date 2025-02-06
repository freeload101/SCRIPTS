
# ollama 
# ollama pull Sweaterdog/Andy-3.5
# ollama pull nomic-embed-text

Invoke-RestMethod "http://localhost:11434/api/generate" -Method Post -Headers @{"Content-Type"="application/json"} -Body (@{"model"="Sweaterdog/Andy-3.5";"prompt"="craft a wooden pickaxe";"stream"=$false}|ConvertTo-Json);Invoke-RestMethod "http://localhost:11434/api/embeddings" -Method Post -Headers @{"Content-Type"="application/json"} -Body (@{"model"="nomic-embed-text";"prompt"="craft a wooden pickaxe"}|ConvertTo-Json)

