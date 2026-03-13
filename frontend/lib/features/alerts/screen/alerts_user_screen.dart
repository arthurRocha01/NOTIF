//import 'package:flutter/material.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

///import '../providers/alert_provider.dart';
//import '../widgets/alert_card.dart';//
//import '../widgets/alert_history_card.dart';

//import '../../../shared/widgets/loading_indicator.dart';//

//import '../../../core/constants/app_colors.dart';
//import '../../../core/constants/app_spacing.dart';//

//class AlertsUserScreen extends ConsumerStatefulWidget {
 // const AlertsUserScreen({super.key});//

  //@override
  //ConsumerState<AlertsUserScreen> createState() =>
      //_AlertsUserScreenState();//
//}//

//class _AlertsUserScreenState extends ConsumerState<AlertsUserScreen> {
  //@override//
  //void initState() {//
    //super.initState();//

    //Future.microtask(() {//
      //ref.read(alertProvider.notifier).loadActiveAlerts();///
      //ref.read(alertProvider.notifier).loadAlertHistory();
   // });//
 // }//

 // @override
  //Widget build(BuildContext context) {//
    //final provider = ref.watch(alertProvider);//

    //if (provider.isLoadingActive) {
     // return const LoadingIndicator();//
   // }//

    //return ListView(
     // padding: const EdgeInsets.all(AppSpacing.lg),//
     // children: [//
       // ...provider.activeAlerts.map(//
          //(alert) => AlertCard(alert: alert),//
        //),//
      //  const SizedBox(height: 24),//
        //...provider.alertHistory.map(//
         // (alert) => AlertHistoryCard(alert: alert),//
       // ),//
      //],//
   // );//
 // }//
//}//