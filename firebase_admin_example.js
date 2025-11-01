// Example Firebase Admin SDK script (Node.js)
// You would need to set up Firebase Admin SDK for this approach

const admin = require('firebase-admin');
const serviceAccount = require('./path-to-service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function addFavoriteForTobias() {
  try {
    // Find Tobias Hanner's document
    const usersRef = db.collection('users');
    const query = usersRef
      .where('firstName', '==', 'Tobias')
      .where('lastName', '==', 'Hanner');
    
    const snapshot = await query.get();
    
    if (snapshot.empty) {
      console.log('No user found');
      return;
    }
    
    const userDoc = snapshot.docs[0];
    const userData = userDoc.data();
    
    // Get current favorites
    const currentFavorites = userData.favoriteCourses || [];
    
    // Add Stockholms Golfklubb (3928713) if not already present
    if (!currentFavorites.includes(3928713)) {
      currentFavorites.push(3928713);
      
      // Update the document
      await userDoc.ref.update({
        favoriteCourses: currentFavorites,
        updatedAt: new Date().toISOString()
      });
      
      console.log('✅ Added Stockholms Golfklubb to favorites');
    } else {
      console.log('⚠️ Course already in favorites');
    }
    
  } catch (error) {
    console.error('Error:', error);
  }
}

addFavoriteForTobias();