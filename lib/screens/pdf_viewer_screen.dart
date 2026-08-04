import 'package:flutter/material.dart';
import '../services/payment_service.dart';


class PdfViewerScreen extends StatefulWidget {

  final String pdfUrl;
  final String paymentId;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.paymentId,
  });


  @override
  State<PdfViewerScreen> createState() =>
      _PdfViewerScreenState();

}



class _PdfViewerScreenState extends State<PdfViewerScreen> {

  final PaymentService paymentService =
      PaymentService();


  Future<bool> checkAccess() async {

    final status =
        await paymentService.checkPaymentStatus(
          widget.paymentId,
        );


    return status == "paid";

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "PDF Viewer",
        ),
      ),


      body: FutureBuilder<bool>(

        future: checkAccess(),


        builder: (context, snapshot) {


          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );

          }


          if(snapshot.data == true){

            return Center(

              child: Text(
                "PDF Ready:\n${widget.pdfUrl}",
                textAlign: TextAlign.center,
              ),

            );

          }


          return const Center(

            child: Text(
              "Payment required to open PDF",
            ),

          );


        },

      ),

    );

  }

}
