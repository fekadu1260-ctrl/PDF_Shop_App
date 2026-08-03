const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount)
});

const db = getFirestore();

console.log("🔥 Firebase Admin Connected!");

db.collection("users").get()
  .then(snapshot => {
    console.log("Users count:", snapshot.size);
  })
  .catch(error => {
    console.log("Error:", error);
  });
