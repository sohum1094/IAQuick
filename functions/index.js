const functions    = require("firebase-functions");
const admin        = require("firebase-admin");
const PizZip       = require("pizzip");
const Docxtemplater = require("docxtemplater");
const path         = require("path");
const os           = require("os");
const fs           = require("fs");

admin.initializeApp({
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});                     // ← use the Admin SDK
const bucket = admin.storage().bucket();   // ← default bucket (no hard-coded name!)

exports.generateIAQReport = functions.https.onRequest(async (req, res) => {
  if (req.method === 'GET') {
    return res.status(200).send('generateIAQReport is healthy');
  }
  const data = req.body;

  console.log("🔥 generateIAQReport invoked with data:", data);

  const templatePath = "resources/IAQ_Assessment Report_Template.docx";
  const tempTemplate = path.join(os.tmpdir(), "template.docx");
  await bucket.file(templatePath).download({ destination: tempTemplate });

  // 2) load + render
  const content = fs.readFileSync(tempTemplate, "binary");
  const zip     = new PizZip(content);
  const doc     = new Docxtemplater(zip, {
    paragraphLoop: true,
    linebreaks:    true,
  });

  // ← be explicit about exactly the keys you expect
  const contextData = {
    full_date:    data.full_date,
    short_date:   data.short_date,
    site_name:    data.site_name,
    site_address: data.site_address,
  };
  console.log("Rendering with:", contextData);

  try {
    doc.setData(contextData);
    doc.render();
  } catch (err) {
    console.error("Template render failed:", err);
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Template rendering error: " + err.message
    );
  }

  // 3) write out the filled doc
  const outputPath = path.join(os.tmpdir(), `IAQ_Report_${Date.now()}.docx`);
  const buffer     = doc.getZip().generate({ type: "nodebuffer" });
  fs.writeFileSync(outputPath, buffer);

  // 4) upload it
  const destPath = `reports/IAQ_Report_${Date.now()}.docx`;
  await bucket.upload(outputPath, { destination: destPath });

  // 5) create a signed URL and return it
  const file = bucket.file(destPath);
  const [url] = await file.getSignedUrl({
    action:  "read",
    expires: Date.now() + 1000 * 60 * 10,  // 10 minutes
  });

  res.json({ url });
});
