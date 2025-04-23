import 'package:flutter_test/flutter_test.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:pagepilot/pagepilot_platform_interface.dart';
import 'package:pagepilot/pagepilot_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPagepilotPlatform 
    with MockPlatformInterfaceMixin
    implements PagepilotPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PagepilotPlatform initialPlatform = PagepilotPlatform.instance;

  test('$MethodChannelPagepilot is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPagepilot>());
  });

  test('getPlatformVersion', () async {
    Pagepilot pagepilotPlugin = Pagepilot();
    MockPagepilotPlatform fakePlatform = MockPagepilotPlatform();
    PagepilotPlatform.instance = fakePlatform;
  
    expect(await pagepilotPlugin.getPlatformVersion(), '42');
  });
}
