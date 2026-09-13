import 'package:flutter/foundation.dart';

/// Whether this device can run the child side of Safini.
///
/// Child mode exists to block apps, and on iOS that needs the Family Controls
/// entitlement plus a DeviceActivity monitor, neither of which has shipped
/// (SAF-135, SAF-155). A child account on an iPhone would get the coins and
/// tasks with nothing enforcing the limits, so iOS gets "coming soon" instead.
bool get isChildModeAvailable =>
    kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;
