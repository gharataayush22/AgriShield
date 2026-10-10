CREATE TABLE diseases (
    disease_id SERIAL PRIMARY KEY,
    disease_name VARCHAR(100) NOT NULL,
    crop_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE symptoms (
    symptom_id SERIAL PRIMARY KEY,
    symptom_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE disease_symptoms (
    disease_id INT REFERENCES diseases(disease_id) ON DELETE CASCADE,
    symptom_id INT REFERENCES symptoms(symptom_id) ON DELETE CASCADE,
    PRIMARY KEY (disease_id, symptom_id)
);

CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    disease_id INT REFERENCES diseases(disease_id) ON DELETE CASCADE,
    medicine_name VARCHAR(100) NOT NULL,
    dosage VARCHAR(100),
    application_method VARCHAR(200)
);

CREATE TABLE precautions (
    precaution_id SERIAL PRIMARY KEY,
    disease_id INT REFERENCES diseases(disease_id) ON DELETE CASCADE,
    precaution_text VARCHAR(255) NOT NULL
);

SELECT * FROM DISEASES;
SELECT * FROM SYMPTOMS;
SELECT * FROM DISEASE_SYMPTOMS;
SELECT * FROM TREATMENTS;
SELECT * FROM PRECAUTIONS;

-- Diseases (IDs 1 to 5)
INSERT INTO diseases (disease_name, crop_name, description) VALUES
('Late Blight', 'Tomato/Potato', 'Fungal disease that spreads fast in cool, humid weather and rots leaves, stems and fruit.'),
('Powdery Mildew', 'Cucumber', 'Fungal disease that forms a white powder-like layer on leaves.'),
('Bacterial Leaf Blight', 'Rice', 'Bacterial disease that causes leaf edges to turn yellow and dry out.'),
('Early Blight', 'Tomato', 'Fungal disease that starts on older leaves with ring-shaped brown spots.'),
('Leaf Curl Virus', 'Tomato/Chilli', 'Virus spread by whiteflies that curls and shrinks the leaves.');

SELECT * FROM DISEASES;

-- Symptoms (IDs 1 to 15)
INSERT INTO symptoms (symptom_name) VALUES
('Dark brown spots on leaves'),
('White fungal growth under leaves'),
('Wilting leaves'),
('Brown lesions on stem'),
('Fruit rot'),
('White powdery coating on leaves'),
('Leaves curling'),
('Yellowing leaves'),
('Stunted growth'),
('Yellow stripes on leaf edges'),
('Leaves drying from tip'),
('Ring-shaped brown spots'),
('Leaf drop'),
('Whiteflies present'),
('Small crinkled leaves');

SELECT * FROM SYMPTOMS;

-- Which symptom belongs to which disease
INSERT INTO disease_symptoms (disease_id, symptom_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),
(2,6),(2,7),(2,8),(2,9),
(3,10),(3,11),(3,3),
(4,12),(4,8),(4,13),(4,1),
(5,7),(5,8),(5,9),(5,14),(5,15);

SELECT * FROM DISEASE_SYMPTOMS;

-- Treatments
INSERT INTO treatments (disease_id, medicine_name, dosage, application_method) VALUES
(1, 'Mancozeb', '2.5 g per litre of water', 'Spray on leaves every 7-10 days'),
(1, 'Chlorothalonil', '2 g per litre of water', 'Spray on leaves and stems'),
(2, 'Wettable Sulphur', '2-3 g per litre of water', 'Spray on both sides of leaves'),
(2, 'Hexaconazole', '1 ml per litre of water', 'Spray at first sign of disease'),
(3, 'Copper Oxychloride', '2.5 g per litre of water', 'Spray on the whole plant'),
(3, 'Streptocycline', '0.15 g per litre of water', 'Mix with copper spray and apply'),
(4, 'Mancozeb', '2.5 g per litre of water', 'Spray every 10 days'),
(4, 'Chlorothalonil', '2 g per litre of water', 'Spray on leaves'),
(5, 'Imidacloprid', '0.3 ml per litre of water', 'Spray to kill whiteflies that spread the virus'),
(5, 'Neem Oil', '5 ml per litre of water', 'Spray weekly as a preventive');

SELECT * FROM TREATMENTS;

-- Precautions
INSERT INTO precautions (disease_id, precaution_text) VALUES
(1, 'Remove and destroy infected plant parts'),
(1, 'Avoid watering leaves in the evening'),
(1, 'Keep proper spacing between plants'),
(2, 'Ensure good air circulation around plants'),
(2, 'Avoid overhead watering'),
(3, 'Use disease-free seeds'),
(3, 'Drain excess water from the field'),
(3, 'Avoid too much nitrogen fertilizer'),
(4, 'Rotate crops every season'),
(4, 'Remove fallen infected leaves'),
(5, 'Control whiteflies with yellow sticky traps'),
(5, 'Uproot and burn infected plants early');

SELECT * FROM PRECAUTIONS;

SELECT d.disease_name, COUNT(*) AS matched_symptoms
FROM diseases d
JOIN disease_symptoms ds ON d.disease_id = ds.disease_id
WHERE ds.symptom_id IN (1, 8, 13)
GROUP BY d.disease_name
ORDER BY matched_symptoms DESC;

-- New diseases (IDs 6 to 10)
INSERT INTO diseases (disease_name, crop_name, description) VALUES
('Downy Mildew', 'Grapes/Cucumber', 'Fungal-like disease that causes yellow patches on top of leaves and fuzzy growth underneath.'),
('Bacterial Wilt', 'Brinjal/Tomato', 'Bacterial disease that blocks water movement inside the plant and causes sudden wilting.'),
('Leaf Rust', 'Wheat', 'Fungal disease that forms orange-brown powdery pustules on leaves.'),
('Cercospora Leaf Spot', 'Groundnut', 'Fungal disease that causes dark spots with a yellow ring around them.'),
('Anthracnose', 'Chilli/Mango', 'Fungal disease that causes sunken dark spots on fruits and leaves.');

SELECT * FROM DISEASES;

-- New symptoms (IDs 16 to 21)
INSERT INTO symptoms (symptom_name) VALUES
('Yellow patches on upper leaf surface'),
('Sudden plant collapse'),
('Brown discoloration inside stem'),
('Orange-brown pustules on leaves'),
('Yellow halo around leaf spots'),
('Sunken dark spots on fruit');

SELECT * FROM SYMPTOMS;

-- Link symptoms to diseases (some reuse old symptoms)
INSERT INTO disease_symptoms (disease_id, symptom_id) VALUES
(6,16),(6,2),(6,13),(6,8),
(7,3),(7,17),(7,18),(7,8),
(8,19),(8,8),(8,11),(8,9),
(9,1),(9,20),(9,13),(9,8),
(10,21),(10,5),(10,1),(10,4);

SELECT * FROM DISEASE_SYMPTOMS;

-- Treatments
INSERT INTO treatments (disease_id, medicine_name, dosage, application_method) VALUES
(6, 'Metalaxyl + Mancozeb', '2.5 g per litre of water', 'Spray on both sides of leaves every 10 days'),
(6, 'Copper Oxychloride', '3 g per litre of water', 'Spray on the whole plant'),
(7, 'Copper Oxychloride', '3 g per litre of water', 'Drench the soil around the plant base'),
(7, 'Trichoderma viride', '5 g per litre of water', 'Apply to soil near the roots as a bio-control'),
(8, 'Propiconazole', '1 ml per litre of water', 'Spray at first sign of pustules'),
(8, 'Mancozeb', '2.5 g per litre of water', 'Spray every 10-15 days'),
(9, 'Carbendazim', '1 g per litre of water', 'Spray on leaves, repeat after 15 days'),
(9, 'Chlorothalonil', '2 g per litre of water', 'Spray on the whole plant'),
(10, 'Carbendazim', '1 g per litre of water', 'Spray on fruits and leaves'),
(10, 'Copper Oxychloride', '3 g per litre of water', 'Spray every 10 days');

SELECT * FROM TREATMENTS;

-- Precautions
INSERT INTO precautions (disease_id, precaution_text) VALUES
(6, 'Avoid overhead watering and wet leaves at night'),
(6, 'Prune plants so air can flow through'),
(7, 'Do not grow the same crop in the same soil repeatedly'),
(7, 'Improve soil drainage'),
(7, 'Uproot and destroy wilted plants immediately'),
(8, 'Grow rust-resistant varieties'),
(8, 'Remove nearby weeds that can carry the disease'),
(9, 'Remove and burn fallen infected leaves'),
(9, 'Avoid planting too close together'),
(10, 'Use healthy, disease-free seeds'),
(10, 'Pick and destroy infected fruits'),
(10, 'Avoid injuring fruits during harvest');

SELECT * FROM PRECAUTIONS;

SELECT d.disease_name, d.crop_name, COUNT(*) AS matched_symptoms
FROM diseases d
JOIN disease_symptoms ds ON d.disease_id = ds.disease_id
WHERE ds.symptom_id IN (8, 9, 11)
GROUP BY d.disease_name, d.crop_name
ORDER BY matched_symptoms DESC;

SELECT (SELECT COUNT(*) FROM diseases) AS diseases,
       (SELECT COUNT(*) FROM symptoms) AS symptoms,
       (SELECT COUNT(*) FROM disease_symptoms) AS links,
       (SELECT COUNT(*) FROM treatments) AS treatments,
       (SELECT COUNT(*) FROM precautions) AS precautions;

ALTER TABLE disease_symptoms ADD COLUMN weight INT NOT NULL DEFAULT 1;

UPDATE disease_symptoms ds
SET weight = w.weight
FROM (VALUES
  -- Late Blight
  (1,1,2),(1,2,3),(1,3,1),(1,4,2),(1,5,2),
  -- Powdery Mildew
  (2,6,3),(2,7,1),(2,8,1),(2,9,1),
  -- Bacterial Leaf Blight
  (3,10,3),(3,11,2),(3,3,1),
  -- Early Blight
  (4,12,3),(4,8,1),(4,13,1),(4,1,2),
  -- Leaf Curl Virus
  (5,7,3),(5,8,1),(5,9,1),(5,14,3),(5,15,2),
  -- Downy Mildew
  (6,16,3),(6,2,3),(6,13,1),(6,8,1),
  -- Bacterial Wilt
  (7,3,2),(7,17,3),(7,18,3),(7,8,1),
  -- Leaf Rust
  (8,19,3),(8,8,1),(8,11,1),(8,9,1),
  -- Cercospora Leaf Spot
  (9,1,2),(9,20,3),(9,13,1),(9,8,1),
  -- Anthracnose
  (10,21,3),(10,5,2),(10,1,2),(10,4,2)
) AS w(disease_id, symptom_id, weight)
WHERE ds.disease_id = w.disease_id AND ds.symptom_id = w.symptom_id;

SELECT * FROM disease_symptoms;

SELECT d.disease_name, s.symptom_name, ds.weight
FROM disease_symptoms ds
JOIN diseases d ON d.disease_id = ds.disease_id
JOIN symptoms s ON s.symptom_id = ds.symptom_id
ORDER BY d.disease_id, ds.weight DESC;


ALTER TABLE diseases ADD COLUMN favored_weather VARCHAR(20);

UPDATE diseases SET favored_weather = 'cool'  WHERE disease_id IN (1, 8);
UPDATE diseases SET favored_weather = 'dry'   WHERE disease_id IN (2, 5);
UPDATE diseases SET favored_weather = 'rainy' WHERE disease_id IN (3, 7, 10);
UPDATE diseases SET favored_weather = 'humid' WHERE disease_id IN (4, 6, 9);

SELECT * FROM diseases;

SELECT disease_name, favored_weather FROM diseases ORDER BY disease_id;

SELECT d.disease_name, SUM(ds.weight) AS score
FROM diseases d
JOIN disease_symptoms ds ON d.disease_id = ds.disease_id
WHERE ds.symptom_id IN (1, 8, 13, 12)
GROUP BY d.disease_name
ORDER BY score DESC;


CREATE TABLE farmers (
    farmer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    farmer_code VARCHAR(12) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

SELECT * FROM FARMERS;

CREATE TABLE diagnoses (
    diagnosis_id SERIAL PRIMARY KEY,
    farmer_id INT REFERENCES farmers(farmer_id) ON DELETE CASCADE,
    crop VARCHAR(50),
    weather VARCHAR(20),
    symptoms_text TEXT,
    top_disease VARCHAR(100),
    score INT,
    percent INT,
    created_at TIMESTAMP DEFAULT NOW()
);

SELECT * FROM DIAGNOSES;

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    farmer_id INT REFERENCES farmers(farmer_id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    message VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

SELECT * FROM FEEDBACK;