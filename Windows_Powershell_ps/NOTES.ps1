# example XML parse
(Invoke-RestMethod -Uri 'https://plex.tv/api/users/?X-Plex-Token=_TOKEN_').MediaContainer.User|select Username, Email |ConvertTo-Csv -NoTypeInformation 

