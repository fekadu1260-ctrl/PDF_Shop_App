const express = require("express");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();
const app = express();

app.use(express.json());

console.log("SERVER FILE LOADED");

app.get("/", (req, res) => {
  res.send("PDF Shop API Running");
});


/* =========================
   PDFS
========================= */

app.get("/pdfs", async (req, res) => {
  try {
    const snapshot = await db.collection("pdfs").get();

    const pdfs = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(pdfs);

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


/* =========================
   ORDERS
========================= */

app.post("/orders", async (req, res) => {
  try {
    const order = req.body;

    const docRef = await db.collection("orders").add({
      ...order,
      status: "pending",
      createdAt: new Date()
    });

    res.status(201).json({
      message: "Order created",
      id: docRef.id,
      ...order,
      status: "pending"
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


app.get("/orders", async (req, res) => {
  try {
    const snapshot = await db.collection("orders").get();

    const orders = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(orders);

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


/* =========================
   PAYMENTS
========================= */

app.post("/payments", async (req, res) => {
  try {
    const payment = req.body;

    const docRef = await db.collection("payments").add({
      ...payment,
      status: "pending",
      createdAt: new Date()
    });

    res.status(201).json({
      message: "Payment created",
      id: docRef.id,
      ...payment,
      status: "pending"
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


app.get("/payments", async (req, res) => {
  try {
    const snapshot = await db.collection("payments").get();

    const payments = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(payments);

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});



app.get("/payments/:id", async (req, res) => {
  try {
    const doc = await db.collection("payments").doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({ error: "Payment not found" });
    }

    res.json({
      id: doc.id,
      ...doc.data()
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


app.put("/payments/:id/approve", async (req, res) => {
  try {
    await db.collection("payments").doc(req.params.id).update({
      status: "approved",
      approvedAt: new Date()
    });

    res.json({
      message: "Payment approved",
      id: req.params.id,
      status: "approved"
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


/* =========================
   SERVER
========================= */

app.listen(3000, "0.0.0.0", () => {
  console.log("PDF Shop API running on port 3000");
});
