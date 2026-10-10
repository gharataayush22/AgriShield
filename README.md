# 🌱 AgriShield

**Plant Disease Diagnosis & Treatment Manager** (DBMS Project)

**Contributors:** Aayush Gharat & Krishna Gajara

A web app where a farmer selects the symptoms seen on a crop, and the app finds the most likely diseases from a database and suggests medication and precautions.

## Features

- **Symptom input:** the farmer ticks the visible symptoms (yellowing, spots, wilting, leaf curling, etc.)
- **Disease identification:** symptoms are matched against the database using weighted scoring, so distinctive symptoms count more than vague ones
- **Crop and weather aware:** diseases that don't affect the chosen crop are filtered out, and diseases that thrive in the current weather get a score bonus
- **Treatment recommendations:** medicine, dosage and application method for each disease
- **Preventive measures:** precautions to control the disease and avoid future infection
- **Top 5 matches** shown, with the best one highlighted
- **Farmer accounts and history:** register to get a unique ID, and the best match of each diagnosis is saved to a track record
- **Feedback page:** farmers can rate the app and read others' reviews

## Tech Stack

Python, Flask, PostgreSQL, HTML, CSS

## Database

Eight tables: `diseases`, `symptoms`, `disease_symptoms` (with a weight column), `treatments`, `precautions`, `farmers`, `diagnoses` and `feedback`. The full schema and sample data are in `database.sql`.

## Run Locally

1. Clone the repo and open the folder
2. Create and activate a virtual environment: `python -m venv .venv`, then `.venv\Scripts\Activate.ps1`
3. Install packages: `pip install -r requirements.txt`
4. In pgAdmin, create a database named `plant_disease_db` and run `database.sql` in it
5. Create a `.env` file:
```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=plant_disease_db
   DB_USER=postgres
   DB_PASSWORD=your_password
   SECRET_KEY=any_long_random_text
```
6. Run `python app.py` and open http://127.0.0.1:5000

## Disclaimer

Medicines and dosages are sample data for an academic project and need verification by an agriculture expert for real use.