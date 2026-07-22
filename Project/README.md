# Context-Aware Campus Assistant

A context-aware platform that supports university students by suggesting nearby
points of interest (POIs) based on their location, the time of day and their
personal preferences. The system consists of three components:

- Backend — REST API (Python / FastAPI) with a PostgreSQL + PostGIS spatial database
- Web dashboard — administrative frontend (HTML/JS + Leaflet + Chart.js) served by Nginx
- Mobile app — native Android client (Kotlin / Jetpack Compose)

Course project for *Context-Aware Systems*, University of Bologna, a.y. 2025-2026.

## Requirements

- Docker and Docker Compose
- Android Studio (to build and run the mobile app)
- `adb` (Android Debug Bridge, included with Android Studio)

## Running the server-side platform

Note:if a local PostgreSQL instance is running on your machine (Linux), stop it first to free port 5432:

```
 bash
 sudo systemctl stop postgresql
```

From the project root, start the whole platform (database, backend, dashboard)
with a single command:

```
bash
docker compose up -d --build
```

Once the containers are up:
Web dashboard: http://localhost:5500 |
API documentation (Swagger UI): http://localhost:8000/docs |
PostgreSQL/PostGIS: localhost:5432 

To stop the platform:

```
bash
docker compose down
```

## Running the Android app

The app (in an emulator) reaches the backend on `localhost:8000` through an
adb port reverse. **Before launching the app**, run:

```
adb reverse tcp:8000 tcp:8000
```

Then open the `ContextAware_app` project in Android Studio and run it on an
emulator

### Simulating the user's position

For demonstration purposes, the GPS position can be injected into the Android
emulator and changed in real time:

```
bash
adb emu geo fix <lon> <lat>
```

Example (Bologna city centre): `adb emu geo fix 11.3426 44.4949`

## Project structure

```
Project/
- docker-compose.yml
- backend/            # FastAPI backend 
- frontend/           # Web dashboard served by Nginx
- db/init.sql         # Database initialization script (schema + POI dataset)
- ContextAware_app/   # Android application 
```

For the full description of the architecture, the REST API and the contextual
ranking rule, see the technical report included in the repository.