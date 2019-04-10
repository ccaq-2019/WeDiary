# WeDiary
API to create and retrieve diary files.
## Routes
All routes return Json
- GET `/`: Root route shows if Web API is running
- GET `api/v1/diary/`: returns all confiugration IDs
- GET `api/v1/diary/[ID]`: returns details about a single diary with given ID
- POST `api/v1/diary/`: creates a new diary
