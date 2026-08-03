const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

async function getPdfs() {
  try {
    console.log("📚 Reading PDFs...");

    const snapshot = await db.collection("pdfs").get();

    console.log("Total PDFs:", snapshot.size);

    snapshot.forEach((doc) => {
      console.log("--------------------");
      console.log("ID:", doc.id);
      console.log(doc.data());
    });

  } catch (error) {
    console.log("❌ Error:", error);
  }
}

getPdfs();
