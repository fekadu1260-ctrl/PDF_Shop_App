const express = require("express");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();
const app = express();

app.use(express.json());

/* =========================
   ADMIN AUTHENTICATION
========================= */

async function requireAdmin(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        error: "Missing Firebase ID token"
      });
    }

    const idToken = authHeader.substring(7);

    const decodedToken = await getAuth().verifyIdToken(idToken);

    if (decodedToken.admin !== true) {
      return res.status(403).json({
        error: "Admin access required"
      });
    }

    req.user = decodedToken;
    next();

  } catch (err) {
    console.error("Admin authentication failed:", err.message);

    return res.status(401).json({
      error: "Invalid or expired Firebase ID token"
    });
  }
}

/* =========================
   USER AUTHENTICATION
========================= */

async function requireUser(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        error: "Missing Firebase ID token"
      });
    }

    const idToken = authHeader.substring(7);

    const decodedToken = await getAuth().verifyIdToken(idToken);

    req.user = decodedToken;
    next();

  } catch (err) {
    console.error("User authentication failed:", err.message);

    return res.status(401).json({
      error: "Invalid or expired Firebase ID token"
    });
  }
}

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

app.post("/payments", requireUser, async (req, res) => {
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


app.get("/payments", requireAdmin, async (req, res) => {
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



/* =========================
   PAYMENT ACCESS
========================= */

async function requirePaymentOwnerOrAdmin(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        error: "Missing Firebase ID token"
      });
    }

    const idToken = authHeader.substring(7);
    const decodedToken = await getAuth().verifyIdToken(idToken);

    const paymentDoc = await db
      .collection("payments")
      .doc(req.params.id)
      .get();

    if (!paymentDoc.exists) {
      return res.status(404).json({
        error: "Payment not found"
      });
    }

    const payment = paymentDoc.data();

    const isAdmin = decodedToken.admin === true;
    const isOwner = payment.userId === decodedToken.uid;

    if (!isAdmin && !isOwner) {
      return res.status(403).json({
        error: "Access denied"
      });
    }

    req.user = decodedToken;
    req.payment = {
      id: paymentDoc.id,
      ...payment
    };

    next();

  } catch (err) {
    console.error("Payment access check failed:", err.message);

    return res.status(401).json({
      error: "Invalid or expired Firebase ID token"
    });
  }
}

app.get("/payments/:id", requirePaymentOwnerOrAdmin, async (req, res) => {
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


app.put("/payments/:id/approve", requireAdmin, async (req, res) => {
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
