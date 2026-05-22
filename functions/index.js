const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const ONESIGNAL_APP_ID = "da910aed-26e9-43c1-8ff5-2d2b66f49558";
const ONESIGNAL_API_KEY = "os_v2_app_3kiqv3jg5fb4dd7vfuvwn5evlc3bxryjtepe62vzpewfgaiutjfr4z4gogavymjslpf3r7ebftq5dipnoicutxesui3uty64uf3fley";

/**
 * Triggers when a new document is created in the AgentJobs collection.
 * Sends a push notification to ALL approved agents via OneSignal.
 */
exports.notifyAgentsOnNewJob = functions.firestore
  .document("AgentJobs/{jobId}")
  .onCreate(async (snap, context) => {
    const job = snap.data();
    const jobId = context.params.jobId;

    if (job.status !== "pending") {
      console.log(`Job ${jobId} is not pending, skipping notification.`);
      return null;
    }

    try {
      const agentsSnap = await admin
        .firestore()
        .collection("Agents")
        .where("isApproved", "==", true)
        .where("oneSignalPlayerId", "!=", null)
        .get();

      if (agentsSnap.empty) {
        console.log("No agents with OneSignal IDs found.");
        return null;
      }

      const playerIds = agentsSnap.docs
        .map((doc) => doc.data().oneSignalPlayerId)
        .filter((id) => id && id.trim() !== "");

      if (playerIds.length === 0) {
        console.log("No valid player IDs found.");
        return null;
      }

      console.log(`Sending notification to ${playerIds.length} agents.`);

      const serviceType = job.serviceType || "Cleaning";
      const location = job.address || job.location || "a nearby location";
      const heading = "🧹 New Job Available!";
      const message = `A new ${serviceType} job just came in at ${location}. Open the app to accept it!`;

      const response = await axios.post(
        "https://onesignal.com/api/v1/notifications",
        {
          app_id: ONESIGNAL_APP_ID,
          include_player_ids: playerIds,
          headings: { en: heading },
          contents: { en: message },
          data: { jobId: jobId, type: "new_job" },
          android_channel_id: "new_job_channel",
          priority: 10,
          ttl: 3600,
        },
        {
          headers: {
            Authorization: `Key ${ONESIGNAL_API_KEY}`,
            "Content-Type": "application/json",
          },
        }
      );

      console.log("OneSignal response:", JSON.stringify(response.data));
      return null;
    } catch (error) {
      console.error("notifyAgentsOnNewJob error:", error.message);
      return null;
    }
  });