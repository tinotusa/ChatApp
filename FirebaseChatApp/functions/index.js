const functions = require("firebase-functions");
const admin = require("firebase-admin");
const firebaseTools = require("firebase-tools");

admin.initializeApp();

exports.deleteAccount = functions
    .region("australia-southeast1")
    .https.onCall(async (data, context) => {
      if (!context.auth || data.id != context.auth.uid) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Must be logged in or be the account's creator to delete it.",
        );
      }
      const id = data.id;
      const roomsPath = data.roomsPath;
      const messagesPaths = data.messagesPaths;
      const roomImagePaths = data.roomImagePaths;
      const profilePicturePath = data.profilePicturePath;

      await firebaseTools.firestore
          .delete(`users/${id}`, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });
      await firebaseTools.firestore
          .delete(roomsPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });

      for (const messagePath of messagesPaths) {
        await firebaseTools.firestore
            .delete(messagePath, {
              project: process.env.GCLOUD_PROJECT,
              recursive: true,
              yes: true,
              force: true,
            });
      }

      const storage = admin.storage();
      const bucket = storage.bucket();
      for (const roomImagePath of roomImagePaths) {
        const file = bucket.file(roomImagePath);
        file.delete();
      }

      if (profilePicturePath != "") {
        const file = bucket.file(profilePicturePath);
        file.delete();
      }
      await admin.auth().deleteUser(id);
      return {
        id: id,
        roomsPath: roomsPath,
        messagesPaths: messagesPaths,
        profilePicturePath: profilePicturePath,
      };
    });

exports.deleteRoom = functions
    .runWith({
      timeoutSeconds: 540,
      memory: "2GB",
    })
    .region("australia-southeast1")
    .https.onCall(async (data, context) => {
      if (!context.auth || data.id != context.auth.uid) {
        throw new functions.https.HttpsError(
            "permission-denied",
            "Must be logged in and be the room's creator to delete.",
        );
      }
      const roomPath = data.roomPath;
      const messagesPath = data.messagesPath;
      console.log(
          `User ${context.auth.uid} has requested to delete path ${roomPath}
          and ${messagesPath}`,
      );
      await firebaseTools.firestore
          .delete(roomPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });
      await firebaseTools.firestore
          .delete(messagesPath, {
            project: process.env.GCLOUD_PROJECT,
            recursive: true,
            yes: true,
            force: true,
          });
      const storage = admin.storage();

      console.log(data);
      if (data.imagePath != "") {
        const defaultBucket = storage.bucket();
        const file = defaultBucket.file(data.imagePath);
        file.delete();
      }
      return {
        roomPath: roomPath,
        messagesPath: messagesPath,
      };
    });
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
