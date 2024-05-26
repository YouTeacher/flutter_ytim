import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ytim_example/utils/im_theme.dart';


class IMRefreshOnStartHeader extends BuilderHeader {
  IMRefreshOnStartHeader()
      : super(
    triggerOffset: 70,
    clamping: true,
    position: IndicatorPosition.above,
    processedDuration: Duration.zero,
    builder: (ctx, state) {
      if (state.mode == IndicatorMode.inactive ||
          state.mode == IndicatorMode.done) {
        return const SizedBox();
      }
      return Container(
        width: double.infinity,
        height: state.viewportDimension,
        alignment: Alignment.center,
        child: const LoadingIndicator(),
      );
    },
  );
}

class LoadingIndicator extends StatelessWidget {
  final Color? color;

  const LoadingIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return  Center(child: CupertinoActivityIndicator(color: color??themeColor,));
  }
}