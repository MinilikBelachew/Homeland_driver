import 'package:flutter/material.dart';

import 'chapa_pay.dart';

class ChapaPaymentPage extends StatelessWidget {
  final double amountToPay;
  final String accountNumber;

  ChapaPaymentPage({required this.amountToPay, required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chapa Payment",
          style: TextStyle(
            color: Colors.white, // White text for better contrast
            fontWeight: FontWeight.bold, // Bold for emphasis
          ),
        ),
        backgroundColor: Color(0xFF008CBA), // Custom app bar color (blue)
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Payment details section with a gradient container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.lightBlueAccent, Colors.lightBlue.shade600],
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Amount to Pay:",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  Text(
                    "ETB ${amountToPay.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "Account Number:",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70, // Lighter white for subheading
                    ),
                  ),
                  Text(
                    "$accountNumber",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text for better contrast
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0), // Spacing between sections

            // Enhanced button with rounded corners, gradient, and shadow
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.teal, // White text for better contrast
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                shadowColor: Colors.tealAccent[700], // Shadow color
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  ChapaPayment(title: "Payment",fareAmount: amountToPay)));

                // Add your Chapa payment logic here
              },
              child: Text(
                "Pay with Chapa",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
