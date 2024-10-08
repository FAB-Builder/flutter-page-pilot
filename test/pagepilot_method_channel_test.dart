import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pagepilot/pagepilot_method_channel.dart';

void main() {
  MethodChannelPagepilot platform = MethodChannelPagepilot();
  const MethodChannel channel = MethodChannel('pagepilot');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
