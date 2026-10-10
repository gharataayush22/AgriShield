import os
import secrets
from dotenv import load_dotenv
from flask import (Flask, render_template, request, redirect,
                   url_for, session, flash)
from db import get_connection

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("SECRET_KEY", "dev-only-change-me")

WEATHER_OPTIONS = ["dry", "humid", "rainy", "cool"]
WEATHER_BONUS = 2  # extra points when weather matches the disease


# Makes the logged-in farmer's name available in every template
@app.context_processor
def inject_farmer():
    return {"farmer_name": session.get("farmer_name")}


# ---------------------------------------------------------------
# HOME + DIAGNOSIS
# ---------------------------------------------------------------
@app.route("/")
def home():
    conn = get_connection()
    cur = conn.cursor()

    cur.execute("SELECT symptom_id, symptom_name FROM symptoms ORDER BY symptom_name;")
    symptoms = cur.fetchall()

    cur.execute("SELECT crop_name FROM diseases;")
    crops = set()
    for (name,) in cur.fetchall():
        for c in name.split("/"):
            crops.add(c.strip())

    cur.close()
    conn.close()
    return render_template(
        "index.html", symptoms=symptoms, crops=sorted(crops), weathers=WEATHER_OPTIONS
    )


@app.route("/diagnose", methods=["POST"])
def diagnose():
    selected = request.form.getlist("symptoms")
    crop = request.form.get("crop", "")
    weather = request.form.get("weather", "")

    if not selected:
        return render_template(
            "result.html", results=[], empty=True, crop=crop, weather=weather, saved=False
        )

    params = {
        "ids": [int(s) for s in selected],
        "crop": crop,
        "pattern": "%" + crop + "%",
        "weather": weather,
        "bonus": WEATHER_BONUS,
    }

    conn = get_connection()
    cur = conn.cursor()

    cur.execute(
        """
        SELECT d.disease_id, d.disease_name, d.crop_name, d.description,
               SUM(ds.weight) AS symptom_score,
               (SELECT SUM(x.weight) FROM disease_symptoms x
                WHERE x.disease_id = d.disease_id) AS total_weight,
               CASE WHEN d.favored_weather = %(weather)s
                    THEN %(bonus)s ELSE 0 END AS weather_bonus
        FROM diseases d
        JOIN disease_symptoms ds ON d.disease_id = ds.disease_id
        WHERE ds.symptom_id = ANY(%(ids)s)
          AND (%(crop)s = '' OR d.crop_name ILIKE %(pattern)s)
        GROUP BY d.disease_id, d.disease_name, d.crop_name,
                 d.description, d.favored_weather
        ORDER BY SUM(ds.weight) +
                 CASE WHEN d.favored_weather = %(weather)s
                      THEN %(bonus)s ELSE 0 END DESC,
                 d.disease_name
        LIMIT 3;
        """,
        params,
    )
    rows = cur.fetchall()

    results = []
    for row in rows:
        disease_id = row[0]
        symptom_score = row[4]
        total_weight = row[5]
        weather_bonus = row[6]

        cur.execute(
            "SELECT medicine_name, dosage, application_method "
            "FROM treatments WHERE disease_id = %s;",
            (disease_id,),
        )
        treatments = cur.fetchall()

        cur.execute(
            "SELECT precaution_text FROM precautions WHERE disease_id = %s;",
            (disease_id,),
        )
        precautions = [p[0] for p in cur.fetchall()]

        results.append(
            {
                "name": row[1],
                "crop": row[2],
                "description": row[3],
                "score": symptom_score + weather_bonus,
                "percent": round(100 * symptom_score / total_weight),
                "weather_match": weather_bonus > 0,
                "treatments": treatments,
                "precautions": precautions,
            }
        )

    # If a farmer is logged in, save the top result to their history
    saved = False
    if "farmer_id" in session and results:
        cur.execute(
            "SELECT symptom_name FROM symptoms "
            "WHERE symptom_id = ANY(%s) ORDER BY symptom_name;",
            (params["ids"],),
        )
        symptom_names = ", ".join(r[0] for r in cur.fetchall())
        top = results[0]
        cur.execute(
            """
            INSERT INTO diagnoses
                (farmer_id, crop, weather, symptoms_text, top_disease, score, percent)
            VALUES (%s, %s, %s, %s, %s, %s, %s);
            """,
            (
                session["farmer_id"],
                crop or "Not sure",
                weather or "Not sure",
                symptom_names,
                top["name"],
                top["score"],
                top["percent"],
            ),
        )
        conn.commit()
        saved = True

    cur.close()
    conn.close()
    return render_template(
        "result.html", results=results, empty=False, crop=crop, weather=weather, saved=saved
    )


# ---------------------------------------------------------------
# TRACK RECORD: register, login, logout, history
# ---------------------------------------------------------------
@app.route("/track")
def track():
    return render_template("track.html")


@app.route("/register", methods=["POST"])
def register():
    name = request.form.get("name", "").strip()
    if not name:
        flash("Please enter your name.")
        return redirect(url_for("track"))

    conn = get_connection()
    cur = conn.cursor()

    # Generate a unique ID like FARM-4821
    while True:
        code = "FARM-" + str(secrets.randbelow(9000) + 1000)
        cur.execute("SELECT 1 FROM farmers WHERE farmer_code = %s;", (code,))
        if cur.fetchone() is None:
            break

    cur.execute(
        "INSERT INTO farmers (name, farmer_code) VALUES (%s, %s) RETURNING farmer_id;",
        (name, code),
    )
    farmer_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    session["farmer_id"] = farmer_id
    session["farmer_name"] = name
    return render_template("welcome.html", name=name, code=code)


@app.route("/login", methods=["POST"])
def login():
    name = request.form.get("name", "").strip()
    code = request.form.get("code", "").strip().upper()

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        "SELECT farmer_id, name FROM farmers "
        "WHERE LOWER(name) = LOWER(%s) AND farmer_code = %s;",
        (name, code),
    )
    farmer = cur.fetchone()
    cur.close()
    conn.close()

    if farmer is None:
        flash("Name and ID do not match. Please try again.")
        return redirect(url_for("track"))

    session["farmer_id"] = farmer[0]
    session["farmer_name"] = farmer[1]
    return redirect(url_for("history"))


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("home"))


@app.route("/history")
def history():
    if "farmer_id" not in session:
        flash("Please log in to see your track record.")
        return redirect(url_for("track"))

    conn = get_connection()
    cur = conn.cursor()
    cur.execute(
        """
        SELECT created_at, crop, weather, symptoms_text,
               top_disease, score, percent
        FROM diagnoses
        WHERE farmer_id = %s
        ORDER BY created_at DESC;
        """,
        (session["farmer_id"],),
    )
    records = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("history.html", records=records)


# ---------------------------------------------------------------
# FEEDBACK
# ---------------------------------------------------------------
@app.route("/feedback", methods=["GET", "POST"])
def feedback():
    conn = get_connection()
    cur = conn.cursor()

    if request.method == "POST":
        if "farmer_id" not in session:
            flash("Please log in to leave feedback.")
            cur.close()
            conn.close()
            return redirect(url_for("track"))

        message = request.form.get("message", "").strip()
        rating = request.form.get("rating", "")

        if not message or rating not in ["1", "2", "3", "4", "5"]:
            flash("Please choose a rating and write a message.")
        else:
            cur.execute(
                "INSERT INTO feedback (farmer_id, rating, message) VALUES (%s, %s, %s);",
                (session["farmer_id"], int(rating), message[:500]),
            )
            conn.commit()
            flash("Thank you for your feedback!")

        cur.close()
        conn.close()
        return redirect(url_for("feedback"))

    # Public list: only the NAME is shown, never the ID
    cur.execute(
        """
        SELECT f.name, fb.rating, fb.message, fb.created_at
        FROM feedback fb
        JOIN farmers f ON f.farmer_id = fb.farmer_id
        ORDER BY fb.created_at DESC;
        """
    )
    entries = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("feedback.html", entries=entries)


if __name__ == "__main__":
    app.run(debug=True)