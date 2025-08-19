const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const functions = require("firebase-functions");

// Initialize Firebase Admin with a specific app name
try {
  if (!admin.apps.length) {
    admin.initializeApp({
      projectId: "heavenlyhaven2-8940c"
    }, "functions-app");
  }
} catch (error) {
  console.error("Firebase admin initialization error:", error);
}

// Configure nodemailer with your email service (Gmail example)
const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 465,
  secure: true,
  auth: {
    user: 'heavenlyhavens658@gmail.com',
    pass: 'tehpdybpirhvberp'
  }
});

// Verify transporter configuration
transporter.verify(function(error, success) {
  if (error) {
    console.error("Transporter verification failed:", error);
  } else {
    console.log("Transporter is ready to send emails");
  }
});

exports.sendVerificationCode = onDocumentCreated("verification_codes/{emailId}", async (event) => {
  console.log("Function triggered for email:", event.params.emailId);
  
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No data associated with the event");
    return;
  }

  // Get the email from the document ID
  const email = event.params.emailId;
  console.log("Sending verification code to:", email);

  // Get the code from the document data
  const verificationCode = snapshot.data().code;
  console.log("Verification code:", verificationCode);

  const mailOptions = {
    from: {
      name: 'Heavenly Havens',
      address: 'heavenlyhavens658@gmail.com'
    },
    to: email,
    subject: "Your Heavenly Havens Verification Code",
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #f57c00;">Heavenly Havens</h2>
        <p>Thank you for signing up! Here's your verification code:</p>
        <div style="background-color: #f5f5f5; padding: 20px; text-align: center; margin: 20px 0;">
          <h1 style="color: #f57c00; letter-spacing: 5px;">${verificationCode}</h1>
        </div>
        <p>This code will expire in 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
        <p style="color: #666; font-size: 12px;">
          This is an automated message, please do not reply.
        </p>
      </div>
    `
  };

  try {
    console.log("Attempting to send email...");
    const info = await transporter.sendMail(mailOptions);
    console.log("Email sent successfully:", info.response);
    return info;
  } catch (error) {
    console.error("Detailed error sending email:", error);
    console.error("Error stack trace:", error.stack);
    throw new Error(`Failed to send verification email: ${error.message}`);
  }
});

// Function to format date string
function formatDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });
}

// New function to send booking confirmation emails
exports.sendBookingConfirmation = onDocumentCreated("bookings/{bookingId}", async (event) => {
  console.log("Booking confirmation function triggered for:", event.params.bookingId);
  
  const snapshot = event.data;
  if (!snapshot) {
    console.log("No booking data associated with the event");
    return;
  }

  const bookingData = snapshot.data();
  const bookingId = event.params.bookingId;
  const formattedBookingId = `HH-${bookingId.split('_').pop().slice(-6)}`;

  // Format the email content
  const mailOptions = {
    from: {
      name: 'Heavenly Havens',
      address: 'heavenlyhavens658@gmail.com'
    },
    to: bookingData.email,
    subject: `Booking Confirmation - ${formattedBookingId}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h2 style="color: #f57c00; text-align: center;">Heavenly Havens</h2>
        <div style="background-color: #f8f8f8; padding: 20px; border-radius: 8px;">
          <h3 style="color: #333; text-align: center;">Thank You for Your Booking!</h3>
          <p style="color: #666;">Dear ${bookingData.fullName},</p>
          <p style="color: #666;">We're delighted to confirm your reservation at Heavenly Havens. Here are your booking details:</p>
          
          <div style="background-color: #fff; padding: 15px; border-radius: 4px; margin: 20px 0;">
            <p style="margin: 5px 0;"><strong>Booking Number:</strong> ${formattedBookingId}</p>
            <p style="margin: 5px 0;"><strong>City:</strong> ${bookingData.city}</p>
            <p style="margin: 5px 0;"><strong>Check-in Date:</strong> ${formatDate(bookingData.checkInDate)}</p>
            <p style="margin: 5px 0;"><strong>Check-out Date:</strong> ${formatDate(bookingData.checkOutDate)}</p>
            <p style="margin: 5px 0;"><strong>Number of Rooms:</strong> ${bookingData.numberOfRooms}</p>
            <p style="margin: 5px 0;"><strong>Total Cost:</strong> ₹${bookingData.totalCost.toFixed(2)}</p>
            <p style="margin: 5px 0;"><strong>Payment Method:</strong> ${bookingData.paymentMethod}</p>
          </div>

          <p style="color: #666;">We look forward to providing you with a comfortable and memorable stay at Heavenly Havens.</p>
          <p style="color: #666;">If you have any questions or need to modify your reservation, please don't hesitate to contact us.</p>
          
          <div style="text-align: center; margin-top: 20px;">
            <p style="color: #888; font-size: 12px;">This is an automated message, please do not reply.</p>
          </div>
        </div>
      </div>
    `
  };

  try {
    console.log("Attempting to send booking confirmation email...");
    const info = await transporter.sendMail(mailOptions);
    console.log("Booking confirmation email sent successfully:", info.response);
    return info;
  } catch (error) {
    console.error("Error sending booking confirmation email:", error);
    console.error("Error stack trace:", error.stack);
    throw new Error(`Failed to send booking confirmation email: ${error.message}`);
  }
});