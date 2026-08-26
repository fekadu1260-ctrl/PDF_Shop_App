require("dotenv").config();
const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");
const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { getStorage } = require("firebase-admin/storage");
const jwt = require("jsonwebtoken");

const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON
  ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
  : require("./serviceAccountKey.json");

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
   MANUAL CUSTOMER AUTHENTICATION
========================= */

const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  console.warn("WARNING: JWT_SECRET is not set. Customer manual authentication will not work until it is configured.");
}

function createCustomerToken(customer) {
  if (!JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured on the server.");
  }

  return jwt.sign(
    {
      uid: String(customer.id),
      phone: String(customer.phone),
      customer: true
    },
    JWT_SECRET,
    {
      expiresIn: "30d"
    }
  );
}

function verifyCustomerToken(token) {
  if (!JWT_SECRET) {
    throw new Error("JWT_SECRET is not configured on the server.");
  }

  return jwt.verify(token, JWT_SECRET);
}

/*
 * Customer OTP is MANUAL.
 *
 * The server does NOT send SMS.
 * The administrator manually sets the OTP for a phone number.
 * Customers only receive the OTP from the administrator.
 */
app.post("/auth/request-otp", async (req, res) => {
  try {
    const phone = String(req.body.phone || "").trim();

    if (!/^\+2519\d{8}$/.test(phone)) {
      return res.status(400).json({
        error: "Invalid Ethiopian phone number"
      });
    }

    const ref = db.collection("manualOtpRequests").doc(phone.replace("+", ""));

    await ref.set({
      phone,
      status: "waiting_for_manual_otp",
      requestedAt: new Date(),
      verified: false
    }, { merge: true });

    return res.json({
      message: "Verification requested. Please contact the administrator for your manual OTP.",
      status: "waiting_for_manual_otp"
    });

  } catch (err) {
    console.error("Manual OTP request failed:", err.message);

    return res.status(500).json({
      error: err.message
    });
  }
});


app.post("/auth/verify-otp", async (req, res) => {
  try {
    const phone = String(req.body.phone || "").trim();
    const otp = String(req.body.otp || "").trim();

    if (!/^\+2519\d{8}$/.test(phone)) {
      return res.status(400).json({
        error: "Invalid Ethiopian phone number"
      });
    }

    if (!/^\d{6}$/.test(otp)) {
      return res.status(400).json({
        error: "OTP must be exactly 6 digits"
      });
    }

    const otpRef = db.collection("manualOtpRequests").doc(phone.replace("+", ""));
    const otpDoc = await otpRef.get();

    if (!otpDoc.exists) {
      return res.status(400).json({
        error: "No OTP request found for this phone number"
      });
    }

    const otpData = otpDoc.data() || {};

    if (otpData.status !== "waiting_for_manual_otp") {
      return res.status(400).json({
        error: "OTP request is not active"
      });
    }

    if (String(otpData.otp || "") !== otp) {
      return res.status(401).json({
        error: "Incorrect manual OTP"
      });
    }

    const customerRef = db.collection("customers").doc(phone.replace("+", ""));
    const customerDoc = await customerRef.get();

    let customer;

    if (customerDoc.exists) {
      customer = {
        id: customerDoc.id,
        ...customerDoc.data()
      };
    } else {
      customer = {
        id: customerRef.id,
        phone,
        name: "",
        createdAt: new Date()
      };

      await customerRef.set(customer);
    }

    await otpRef.update({
      status: "used",
      verified: true,
      verifiedAt: new Date(),
      otp: null
    });

    const token = createCustomerToken(customer);

    return res.json({
      message: "Manual OTP verified successfully",
      token,
      userId: customer.id,
      phone
    });

  } catch (err) {
    console.error("Manual OTP verification failed:", err.message);

    return res.status(500).json({
      error: err.message
    });
  }
});


/*
 * ADMIN-ONLY MANUAL OTP SETTER
 *
 * This does NOT send anything to the customer.
 * The administrator manually chooses the 6-digit OTP
 * and stores it for the requested phone number.
 */
app.put("/auth/admin/set-manual-otp", requireAdmin, async (req, res) => {
  try {
    const phone = String(req.body.phone || "").trim();
    const otp = String(req.body.otp || "").trim();

    if (!/^\+2519\d{8}$/.test(phone)) {
      return res.status(400).json({
        error: "Invalid Ethiopian phone number"
      });
    }

    if (!/^\d{6}$/.test(otp)) {
      return res.status(400).json({
        error: "OTP must be exactly 6 digits"
      });
    }

    const ref = db.collection("manualOtpRequests").doc(phone.replace("+", ""));

    await ref.set({
      phone,
      otp,
      status: "waiting_for_manual_otp",
      otpSetAt: new Date(),
      otpSetBy: req.user.uid
    }, { merge: true });

    return res.json({
      message: "Manual OTP saved successfully",
      phone,
      status: "waiting_for_manual_otp"
    });

  } catch (err) {
    console.error("Manual OTP setup failed:", err.message);

    return res.status(500).json({
      error: err.message
    });
  }
});


/* =========================
   USER AUTHENTICATION
========================= */

async function requireUser(req, res, next) {
  try {
    const authHeader = req.headers.authorization || "";

    if (!authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        error: "Missing customer authentication token"
      });
    }

    const token = authHeader.substring(7);
    const decodedToken = verifyCustomerToken(token);

    if (decodedToken.customer !== true || !decodedToken.uid) {
      return res.status(401).json({
        error: "Invalid customer authentication token"
      });
    }

    req.user = decodedToken;
    next();

  } catch (err) {
    console.error("Customer authentication failed:", err.message);

    return res.status(401).json({
      error: "Invalid or expired customer authentication token"
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



/* =========================
   CATEGORIES
   ========================= */

app.get("/categories", async (req, res) => {
  try {
    const snapshot = await db.collection("pdfs").get();

    const categoryMap = new Map();

    snapshot.docs.forEach(doc => {
      const data = doc.data();
      const category = String(data.category || "").trim();

      if (category) {
        const key = category.toLowerCase();

        if (!categoryMap.has(key)) {
          categoryMap.set(key, category);
        }
      }
    });

    const categories = Array.from(categoryMap.entries())
      .sort((a, b) => a[1].localeCompare(b[1]))
      .map(([key, name]) => ({
        name
      }));

    res.json(categories);

  } catch (err) {
    console.error("GET /categories error:", err);

    res.status(500).json({
      error: err.message
    });
  }
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
        error: "Missing authentication token"
      });
    }

    const token = authHeader.substring(7);

    // First try Firebase authentication for administrators.
    try {
      const firebaseUser = await getAuth().verifyIdToken(token);
      req.user = firebaseUser;
      return next();
    } catch (_) {
      // Not a Firebase token; try the manual customer JWT.
    }

    const customerUser = verifyCustomerToken(token);

    if (customerUser.customer !== true || !customerUser.uid) {
      return res.status(401).json({
        error: "Invalid authentication token"
      });
    }

    req.user = customerUser;
    next();

  } catch (err) {
    console.error("Order authentication failed:", err.message);

    return res.status(401).json({
      error: "Invalid or expired authentication token"
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
        error: "Missing authentication token"
      });
    }

    const token = authHeader.substring(7);

    let decodedToken;

    // Firebase token = administrator authentication.
    try {
      decodedToken = await getAuth().verifyIdToken(token);
    } catch (_) {
      // Otherwise try manual customer JWT.
      decodedToken = verifyCustomerToken(token);
    }

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
      error: "Invalid or expired authentication token"
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
    const paymentId = req.params.id;
    const paymentRef = db.collection("payments").doc(paymentId);

    const result = await db.runTransaction(async (transaction) => {
      const paymentDoc = await transaction.get(paymentRef);

      if (!paymentDoc.exists) {
        const error = new Error("Payment not found");
        error.statusCode = 404;
        throw error;
      }

      const payment = paymentDoc.data();

      if (!payment.userId || !payment.pdfId) {
        const error = new Error("Payment is missing userId or pdfId");
        error.statusCode = 400;
        throw error;
      }

      const orderRef = db.collection("orders").doc(`payment_${paymentId}`);
      const orderDoc = await transaction.get(orderRef);
      const now = new Date();

      if (!orderDoc.exists) {
        const order = {
          userId: String(payment.userId),
          pdfId: String(payment.pdfId),
          amount: Number(payment.amount),
          status: "paid",
          paymentId: paymentId,
          paymentMethod: String(payment.method || ""),
          paymentReference: String(payment.paymentReference || ""),
          createdAt: payment.createdAt || now,
          paidAt: now
        };

        if (!Number.isFinite(order.amount) || order.amount < 0) {
          const error = new Error("Invalid payment amount");
          error.statusCode = 400;
          throw error;
        }

        transaction.set(orderRef, order);
      } else {
        const existingOrder = orderDoc.data() || {};

        if (existingOrder.status !== "paid") {
          transaction.update(orderRef, {
            status: "paid",
            paidAt: now
          });
        }
      }

      transaction.update(paymentRef, {
        status: "approved",
        approvedAt: now
      });

      return {
        orderId: orderRef.id,
        alreadyExisted: orderDoc.exists
      };
    });

    res.json({
      message: result.alreadyExisted
          ? "Payment approved; existing order confirmed"
          : "Payment approved and order created",
      id: paymentId,
      status: "approved",
      orderId: result.orderId
    });

  } catch (err) {
    console.error("Payment approval failed:", err.message);

    const statusCode = Number.isInteger(err.statusCode)
        ? err.statusCode
        : 500;

    res.status(statusCode).json({
      error: err.message
    });
  }
});

/* =========================
   SERVER
========================= */

const PORT = process.env.PORT || 3000;

app.listen(PORT, "0.0.0.0", () => {
  console.log("PDF Shop API running on port 3000");
});
