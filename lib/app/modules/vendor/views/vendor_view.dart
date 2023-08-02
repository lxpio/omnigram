import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/vendor_controller.dart';

class VendorView extends GetView<VendorController> {
  const VendorView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VendorView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'VendorView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
