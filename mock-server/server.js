const express = require('express');
const admin = require('firebase-admin');
const bodyParser = require('body-parser');
const serviceAccount = require('C:\\Users\\Dorukan\\StudioProjects\\noapimockserver\\noapimockserver-firebase-adminsdk-8jg1c-f98be66741.json');
// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://noapimockserver.firebaseio.com',
});

const app = express();
const db = admin.firestore();

app.use(express.json());

async function handleRequest(req, res, method) {
  const { mockServerId, collectionName } = req.params;
  const requestUrl = `${req.protocol}://${req.get('host')}${req.originalUrl}`;

  try {
    const snapshot = await db.collection('mockServers')
      .doc(mockServerId)
      .collection('requests')
      .where('method', '==', method)
      .where('url', '==', requestUrl)
      .get();

    if (snapshot.empty) {
      return res.status(404).json({ error: 'Request not found' });
    }

    const existingRequest = snapshot.docs[0].data();
    return res.status(200).json(JSON.parse(existingRequest.body || '{}'));
  } catch (error) {
    console.error('Error processing request:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

app.get('/mockServers/:mockServerId/:collectionName', (req, res) => {
  handleRequest(req, res, 'GET');
});

app.post('/mockServers/:mockServerId/:collectionName', (req, res) => {
  handleRequest(req, res, 'POST');
});

app.delete('/mockServers/:mockServerId/:collectionName', (req, res) => {
  handleRequest(req, res, 'DELETE');
});

app.put('/mockServers/:mockServerId/:collectionName', (req, res) => {
  handleRequest(req, res, 'PUT');
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});