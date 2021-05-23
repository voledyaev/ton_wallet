import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final bool isOut;
  final String now;
  final int? value;
  final String? address;
  final int? fees;

  const TransactionCard({
    required this.isOut,
    required this.now,
    required this.value,
    required this.address,
    required this.fees,
  });

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: buildBody(context),
        ),
      );

  Column buildBody(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAddress(context),
          const SizedBox(height: 25),
          buildInfo(context),
        ],
      );

  Row buildInfo(BuildContext context) => Row(
        children: [
          Expanded(
            child: buildDateTime(context),
          ),
          Expanded(
            child: buildValueInfo(context),
          ),
        ],
      );

  Column buildValueInfo(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (value != null)
            Text(
              (value! / 1e9).toStringAsFixed(9),
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.right,
            ),
          if (fees != null)
            Text(
              'Fees: ${(fees! / 1e9).toStringAsFixed(9)}',
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.right,
            ),
        ],
      );

  Text buildDateTime(BuildContext context) => Text(
        now,
        style: Theme.of(context).textTheme.bodyText2,
        textAlign: TextAlign.left,
      );

  Row buildAddress(BuildContext context) => Row(
        children: [
          Icon(
            isOut ? Icons.arrow_forward : Icons.arrow_back,
            color: Colors.white,
          ),
          if (address != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  address!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
        ],
      );
}
