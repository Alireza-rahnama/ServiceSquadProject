/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const admin = require("firebase-admin");
const functions = require("firebase-functions");

// TODO: it would be wise to put the secret key in a .env file
// and .gitignore that .env file to prevent it from ever being
// checked into version control. This key is a test key and
// may only be used for test transactions (no real money can
// be moved with this key).


const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const { defineSecret } = require("firebase-functions/params");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();
const db = admin.firestore();

// const stripe = require("stripe")(functions.config().keys.stripe_secret_key);
// const stripe = require("stripe")(defineSecret("STRIPE_SECRET_KEY"));
// const endpointSecret = functions.config().keys.stripe_wh_signing;
// const endpointSecret = defineSecret("STRIPE_WEBHOOKS_SIGNING_KEY");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const endpointSecret = process.env.STRIPE_WEBHOOKS_SIGNING_KEY;

/*
 Body:
     email: email address of customer
     ServiceID: ID of Service listing
     startEpoch: Start time since Unix Epoch of the booking.
     bookingLength: The duration of the booking specified as an int and represents 30 minute blocks.
                    Expects a number between 1 and 48.
     clientID: ID of client booking is for.
     address: address for booking.
*/
exports.stripePaymentIntentRequest = onRequest(async (req, res) => {
    try {
        let customerId;

        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });
                
        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        } else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.data.id;
        }

        //Creates a temporary secret key linked with the customer 
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2023-10-16' }
        );

        let serviceID = req.body.serviceID;
        let bookingStartEpoch = req.body.startEpoch;
        let bookingLength = parseInt(req.body.bookingLength); // Number of 30 minute blocks the user selected.
        let clientID = req.body.clientID;
        let address = req.body.address;

        let serviceDocData;

        var query = await db.collection('available_professional_services')
            .where('id', '==', serviceID)
            .get().then(result => {
                result.forEach((doc) => {
                    serviceDocData = doc.data();
                });
            });

        if (bookingLength < 1 || bookingLength > 48) {
            res.status(404).send({ success: false, error: "Invalid booking length." })
            return;
        }

        let wage = 9999999999;

        if (serviceDocData != undefined && serviceDocData["wage"] != undefined) {
            wage = serviceDocData["wage"];
        } else {
            res.status(404).send({ success: false, error: "No such service listing" })
            return;
        }

        let amount = bookingLength / 2 * wage * 100;

        // TODO: Check if a booking already exists for that day
        let bookingOrderDoc = db.doc("pending_booking_information/" + serviceID + "_" + bookingStartEpoch);
        bookingOrderDoc.set({
            serviceID: serviceID,
            bookingStartEpoch: bookingStartEpoch,
            bookingLength: bookingLength,
            clientID: clientID,
            address: address,
            wage: wage,
            total_amount: amount,
        });
        
        // Creates a new payment intent with amount passed in from the client
        const paymentIntent = await stripe.paymentIntents.create({
            amount: amount,
            currency: 'cad',
            customer: customerId,
            metadata: {
                paymentType: 'booking',
                bookingID: bookingOrderDoc.id,
                serviceID: serviceID,
                bookingStart: bookingStartEpoch,
                bookingLength: bookingLength,
                clientID: clientID,
                address: address,
            }
        })

        res.status(200).json({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            checkoutItems: [
                {
                    name: 'wage',
                    quantity: bookingLength / 2,
                    price: wage,
                },
            ],
            total_amount: amount,
            bookingID: bookingOrderDoc.id,
            success: true,
        });
        
    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
});

/* This webhook is called when a stripe payment succeeds or fails. */
exports.stripeWebHook = onRequest(async (req, res) => {

    // First we verify that we are communicating with Stripe.
    // Otherwise, an adversary may forge a request.

    const sig = req.headers['stripe-signature'];

    let event;
  
    try {
      event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    }
    catch (err) {
      res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Handle hook event:
    switch (event.type) {
        case 'payment_intent.succeeded':
            const successfulPaymentIntent = event.data.object;
            await handlePaymentIntentSucceeded(successfulPaymentIntent);
            break;
        case 'payment_intent.payment_failed':
            const failedPaymentIntent = event.data.object;
            // TODO: Handle failed payments. May want to notify the user using
            // firestore.
            //handlePaymentIntentFailed(paymentIntent);
            break;
    }

    // Return a response to acknowledge receipt of the event
    res.json({received: true});
});

async function handlePaymentIntentSucceeded(intent) {

    /*
        metadata: {
            paymentType: 'booking',
            serviceID: serviceID,
            bookingStart: bookingStartEpoch,
            bookingLength: bookingLength,
            clientID: clientID,
            address: address,
        }
    */

        /*
        id,
        serviceID,
        bookingStart,
        bookingLength,
        dateCreated,
        clientID,
        address
        */
    
    let data = intent.metadata;
    if (data.paymentType == 'booking') {
        let doc = db.doc("service_bookings/" + data.bookingID);
        await doc.create({
            serviceID: data.serviceID,
            bookingStart: data.bookingStart,
            bookingLength: data.bookingLength,
            dateCreated: Date.now(),
            clientID: data.clientID,
            address: data.address
        });
    }

}
