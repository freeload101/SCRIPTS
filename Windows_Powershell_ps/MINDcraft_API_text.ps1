# prompts ... 
# !goal("in the following order Craft a wooden_pickaxe, stone_pickaxe , iron_pickaxe and finaly a diamond_pickaxe")
 
 
# !goal("use !nearbyBlocks to find resouces needed to Craft a wooden_pickaxe")


# ollama 
# ollama pull Sweaterdog/Andy-3.5
# ollama pull nomic-embed-text

Invoke-RestMethod "http://localhost:11434/api/generate" -Method Post -Headers @{"Content-Type"="application/json"} -Body (@{"model"="Sweaterdog/Andy-3.5";"prompt"="craft a wooden pickaxe";"stream"=$false}|ConvertTo-Json);Invoke-RestMethod "http://localhost:11434/api/embeddings" -Method Post -Headers @{"Content-Type"="application/json"} -Body (@{"model"="nomic-embed-text";"prompt"="craft a wooden pickaxe"}|ConvertTo-Json)

