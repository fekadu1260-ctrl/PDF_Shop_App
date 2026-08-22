const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { getStorage } = require("firebase-admin/storage");

const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);

initializeApp({
  credential: cert(serviceAccount),
  storageBucket: "eatandfee.firebasestorage.app"
});

const db = getFirestore();
const bucket = getStorage().bucket();
const app = express();

app.use(express.json());

// =========================
// LOCAL PDF FILE STORAGE
// =========================
const uploadsDir = path.join(__dirname, "uploads");

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const pdfStorage = multer.memoryStorage();

const pdfUpload = multer({
  storage: pdfStorage,
  limits: {
    fileSize: 100 * 1024 * 1024,
  },
  fileFilter: (_req, file, cb) => {
    const isPdf =
      file.mimetype === "application/pdf" ||
      path.extname(file.originalname).toLowerCase() === ".pdf";

    if (!isPdf) {
      return cb(new Error("Only PDF files are allowed."));
    }

    cb(null, true);
  },
});


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
   PDF FILE UPLOAD
========================= */

app.post("/upload-pdf", requireAdmin, (req, res) => {
  pdfUpload.single("file")(req, res, async (err) => {
    if (err) {
      console.error("PDF upload failed:", err.message);
      return res.status(400).json({
        error: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        error: "No PDF file received"
      });
    }

    try {
      const safeName = path
        .basename(req.file.originalname)
        .replace(/[^a-zA-Z0-9._-]/g, "_");

      const fileName = `${Date.now()}-${safeName}`;
      const file = bucket.file(`pdfs/${fileName}`);

      await file.save(req.file.buffer, {
        metadata: {
          contentType: "application/pdf",
          metadata: {
            originalName: req.file.originalname
          }
        },
        resumable: false
      });

      const [signedUrl] = await file.getSignedUrl({
        action: "read",
        expires: "12-31-2035"
      });

      console.log("PDF uploaded to Firebase Storage:", fileName);

      return res.status(201).json({
        message: "PDF uploaded successfully to Firebase Storage",
        fileName,
        originalName: req.file.originalname,
        size: req.file.size,
        fileUrl: signedUrl
      });

    } catch (uploadError) {
      console.error("Firebase Storage upload failed:", uploadError);

      return res.status(500).json({
        error: "Firebase Storage upload failed",
        details: uploadError.message
      });
    }
  });
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
   ADMIN PDF MANAGEMENT
========================= */

app.post("/pdfs", requireAdmin, async (req, res) => {
  try {
    const {
      title,
      description,
      price,
      category,
      fileUrl
    } = req.body;

    if (!title || !fileUrl) {
      return res.status(400).json({
        error: "Title and fileUrl are required"
      });
    }

    const numericPrice = Number(price);

    if (!Number.isFinite(numericPrice) || numericPrice < 0) {
      return res.status(400).json({
        error: "Invalid price"
      });
    }

    const docRef = await db.collection("pdfs").add({
      title: String(title).trim(),
      description: String(description || "").trim(),
      price: numericPrice,
      category: String(category || "General").trim(),
      fileUrl: String(fileUrl).trim(),
      createdAt: new Date()
    });

    res.status(201).json({
      message: "PDF created",
      id: docRef.id,
      title: String(title).trim(),
      description: String(description || "").trim(),
      price: numericPrice,
      category: String(category || "General").trim(),
      fileUrl: String(fileUrl).trim()
    });
  } catch (err) {
    console.error("PDF creation failed:", err.message);

    res.status(500).json({
      error: err.message
    });
  }
});

/* =========================
   ORDERS
========================= */

app.post("/orders", requireUser, async (req, res) => {
  try {
    const { pdfId, amount, status, createdAt } = req.body;

    if (!pdfId || amount == null) {
      return res.status(400).json({
        error: "pdfId and amount are required"
      });
    }

    const order = {
      userId: req.user.uid,
      pdfId: String(pdfId),
      amount: Number(amount),
      status: String(status || "pending"),
      createdAt: createdAt ? new Date(createdAt) : new Date()
    };

    if (!Number.isFinite(order.amount) || order.amount < 0) {
      return res.status(400).json({
        error: "Invalid amount"
      });
    }

    const docRef = await db.collection("orders").add(order);

    res.status(201).json({
      message: "Order created",
      id: docRef.id,
      ...order
    });

  } catch (err) {
    console.error("Order creation failed:", err.message);
    res.status(500).json({
      error: err.message
    });
  }
});


async function requireUserOrAdmin(req, res, next) {
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
    console.error("Order authentication failed:", err.message);
    return res.status(401).json({
      error: "Invalid or expired Firebase ID token"
    });
  }
}

app.get("/orders", requireUserOrAdmin, async (req, res) => {
  try {
    const isAdmin = req.user.admin === true;

    let snapshot;

    if (isAdmin) {
      snapshot = await db.collection("orders").get();
    } else {
      snapshot = await db.collection("orders")
        .where("userId", "==", req.user.uid)
        .get();
    }

    const orders = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));

    res.json(orders);

  } catch (err) {
    console.error("Order loading failed:", err.message);
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
    const { pdfId, amount, method, paymentReference } = req.body;

    if (!pdfId || amount == null || !method || !paymentReference) {
      return res.status(400).json({
        error: "pdfId, amount, method and paymentReference are required"
      });
    }

    const payment = {
      userId: req.user.uid,
      pdfId,
      amount,
      method,
      paymentReference
    };

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
