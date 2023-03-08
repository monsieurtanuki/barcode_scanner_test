import 'package:visibility_detector/visibility_detector.dart';

extension VisibilityInfoExt on VisibilityInfo {
  bool get visible => visibleBounds.height > 0.0;
}
