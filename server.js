app.post("/orders", async (req, res) => app.post("/orders", async (req, res) => {

  try {

    const order = await Order.create(req.body);

    res.status(201).json(order);

  } catch (error) {

    res.status(500).json({
      error: error.message
    });

  }

});{

  const order = req.body;
const Order = require("./models/Order");
  console.log("New order:", order);

  res.status(201).json({
    message: "Order created",
    ...order
  });

});const express = require("express");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const app = express();

app.use(express.json());

app.get("/pdfs", async (req, res) => {
  try {
    const snapshot = await db.collection("pdfs").get();

    let pdfs = [];

    snapshot.forEach((doc) => {
      pdfs.push({
        id: doc.id,
        ...doc.data()
      });
    });

    res.json(pdfs);

  } catch (error) {
    res.status(500).json({
      error: error.message
    });
  }
});

app.listen(3000, () => {
  console.log("🚀 PDF Shop API running on port 3000");
});
