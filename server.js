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


app.post("/orders", async (req, res) => {
  try {
    const order = req.body;

    const docRef = await db.collection("orders").add({
      ...order,
      status: "pending",
      createdAt: new Date()
    });

    res.json({
      message: "Order created",
      id: docRef.id
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});


app.get("/orders", async (req, res) => {
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
});  try {
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


app.listen(3000, () => {
  console.log("PDF Shop API running on port 3000");
});
app.post("/payments", async (req, res) => {
  try {

    const payment = req.body;

    const docRef = await db.collection("payments").add({
      ...payment,
      status: "pending",
      createdAt: new Date()
    });

    res.json({
      message: "Payment created",
      id: docRef.id
    });

  } catch (err) {

    res.status(500).json({
      error: err.message
    });

  }
});


app.listen(3000, () => {
  console.log("PDF Shop API running on port 3000");
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

