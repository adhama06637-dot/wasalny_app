import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route.dart' as app_route;
import '../providers/app_provider.dart';
import 'app_colors.dart';
import 'main_screen.dart';

class PaymentScreen extends StatelessWidget{ final app_route.Route route; const PaymentScreen({super.key,required this.route});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title: const Text('Payment')), body:Padding(padding: const EdgeInsets.all(18), child:Column(children:[Container(padding: const EdgeInsets.all(18), decoration:cardDecoration(), child:Column(children:[const Icon(Icons.payment,color:AppColors.primary,size:46), const SizedBox(height:10), Text('${route.cost.toStringAsFixed(0)} EGP', style: const TextStyle(fontSize:30,fontWeight:FontWeight.bold)), Text('${route.start} → ${route.end}', style: const TextStyle(color:AppColors.muted)), const Divider(height:30), const Row(children:[Icon(Icons.wallet,color:AppColors.primary), SizedBox(width:8), Text('Pay from Wallet')])])), const Spacer(), SizedBox(width:double.infinity,height:54, child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white), onPressed:() async{final p=context.read<AppProvider>(); final b=await p.bookSelectedRoute(); if(b!=null)p.payBooking(b); if(context.mounted)Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder:(_)=>const MainScreen()), (_)=>false);}, child: const Text('Confirm Payment')))])));
}