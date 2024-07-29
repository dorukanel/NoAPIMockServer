const express = require('express');
const admin = require('firebase-admin');
const bodyParser = require('body-parser');
const serviceAccount = require('C:\\Users\\Dorukan\\StudioProjects\\noapimockserver\\noapimockserver-firebase-adminsdk-8jg1c-f98be66741.json');


const app = express();
app.use(bodyParser.json());

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://noapimockserver.firebaseio.com',
});

const db = admin.firestore();

app.get('/mockServers/:mockServerId/:collectionName/:docId?', async (req, res) => {
  const { mockServerId, collectionName, docId } = req.params;
  const queryParams = req.query;

  console.log(`Received request for mockServerId: ${mockServerId}, collectionName: ${collectionName}, docId: ${docId}, queryParams: ${JSON.stringify(queryParams)}`);

  try {
    if (docId) {
      // Fetch a single document
      const docRef = db.collection(`mockServers/${mockServerId}/requests`).doc(docId);
      const doc = await docRef.get();
      if (doc.exists) {
        return res.status(200).json(JSON.parse(doc.data().body));
      } else {
        return res.status(404).send('Document not found');
      }
    } else {
      // Fetch all documents in the 'requests' subcollection
      const collectionRef = db.collection(`mockServers/${mockServerId}/requests`);
      const snapshot = await collectionRef.get();
      if (snapshot.empty) {
        return res.status(404).send('No data found');
      }

      // Debugging: Print the body field before parsing
      const documents = snapshot.docs.map((doc) => {
        console.log(`Document ID: ${doc.id}`);
        console.log(`Body: ${doc.data().body}`);
        return doc;
      });

      // Apply query parameters to filter the results
      let collectionData;
      try {
        collectionData = documents.map((doc) => JSON.parse(doc.data().body));
      } catch (error) {
        console.error('Error parsing JSON:', error);
        return res.status(500).send('Error parsing JSON data');
      }

      if (queryParams.limit) {
        collectionData = collectionData.slice(0, parseInt(queryParams.limit, 10));
      }

      return res.status(200).json(collectionData);
    }
  } catch (error) {
    console.error('Error fetching data:', error);
    return res.status(500).send('Error fetching data');
  }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});