const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

const pdfData = {
  title: "Civil Engineering BOQ Guide",
  description: "Construction quantity estimation and BOQ basics",
  price: 100,
  category: "Engineering",
  fileUrl: "sample_file.pdf",
  createdAt: new Date()
};

db.collection("pdfs")
  .add(pdfData)
  .then(doc => {
    console.log("✅ PDF Added ID:", doc.id);
  })
  .catch(error => {
    console.log("❌ Error:", error);
  });
