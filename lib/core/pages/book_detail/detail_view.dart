import 'package:flutter/material.dart';

class DetailView extends StatelessWidget {
  const DetailView({Key? key}) : super(key: key);

  static get routeName => 'bookdetail';
  static get routeLocation => '/reader/details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          height: 350,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: AssetImage('assets/images/logo-green.png'),
                fit: BoxFit.cover,
              )),
          // child: ,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          'Hello World',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          'Hello World',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ]),
    );
  }
}
