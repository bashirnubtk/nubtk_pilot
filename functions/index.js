const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { GoogleGenerativeAI } = require("@google/generative-ai");

admin.initializeApp();

const genAI = new GoogleGenerativeAI(functions.config().gemini.key);

exports.analyzeProject = functions.https.onCall(async (data, context) => {
  try {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in."
      );
    }

    const userInput = data.text;

    if (!userInput) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Text input is required."
      );
    }

    const model = genAI.getGenerativeModel({ model: "gemini-pro" });

    const prompt = `
You are a professional academic project evaluator.

Analyze the following project description and respond ONLY in valid JSON format.

Return:
{
  "summary": "...",
  "strength": "...",
  "weakness": "...",
  "score": 0-100,
  "improvement": "..."
}

Project:
${userInput}
`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    // Parse Gemini response to JSON
    const cleaned = text.replace(/```json|```/g, "").trim();
    const jsonOutput = JSON.parse(cleaned);

    // Save to Firestore
    await admin.firestore().collection("ai_results").add({
      userId: context.auth.uid,
      input: userInput,
      output: jsonOutput,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return jsonOutput;

  } catch (error) {
    console.error(error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});
