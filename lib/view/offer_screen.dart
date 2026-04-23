import 'package:flutter/material.dart';
import 'package:trippy_customer/utils/images.dart';

class OfferScreen extends StatelessWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Offers",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context,index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                offerBanner(),
                SizedBox(height: 20),],
            );
          }
        ),
      ),
    );
  }

  Widget offerBanner() {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          height: 120,
          child: Image.asset(
            Images.OfferScreenBannerImg,
            fit: BoxFit.contain,
            height: 80,
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "৭০০ টাকা ক্যাশব্যাক জেতার সুযোগ!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "১ এপ্রিল ৩০ এপ্রিল ২০২৬ পর্যন্ত গাড়িবুক-এ যেকোনো ইন্টারসিটি ট্রিপেই ৭০০ টাকা ক্যাশব্যাক জেতার সুযোগ!",
                style: TextStyle(color: Color(0xffb3b3b3), fontSize: 13),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {},
                child: Text(
                  "See Details",
                  style: TextStyle(
                    color: Colors.blue,
                    decorationColor: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
