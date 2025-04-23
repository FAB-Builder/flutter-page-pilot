import 'package:flutter/material.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pagepilot/widgets/page_pilot_banner.dart';
import 'package:pagepilot_example/page_pilot_keys.dart';


Future<List<PagePilotBannerItem>> fetchBannerItems(String apiEndpoint) async {
  final url = Uri.parse(apiEndpoint);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final apiResponse = response.body;
    final responseJson = jsonDecode(apiResponse);
    if (responseJson['rows'] == null ||
        (responseJson['rows'] as List).isEmpty) {
      throw Exception("No banner data found");
    }
    final items = (responseJson['rows'] as List)
        .map((item) => PagePilotBannerItem.fromJson(item))
        .toList();
    items.sort((a, b) {
      final seqA = a.sequence;
      final seqB = b.sequence;

      if (seqA == null && seqB == null) return 0;
      if (seqA == null) return 1;
      if (seqB == null) return -1;

      return seqA.compareTo(seqB);
    });
    return items;
  } else {
    throw Exception("Failed to load banner data");
  }
}

class App extends StatefulWidget {
  final String platformVersion;
  final Pagepilot pagepilotPlugin;

  const App({
    super.key,
    required this.platformVersion,
    required this.pagepilotPlugin,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late Future<List<List<PagePilotBannerItem>>> _bannerItemsFuture;

  @override
  void initState() {
    super.initState();
    _bannerItemsFuture = Future.wait([
      fetchBannerItems(
          "https://pagepilot.fabbuilder.com/api/tenant/6655bc2b30a6760d8f897581/client/app-banners?filter[isActive]=true&filter[identifier]=TEST_HOME"),
      fetchBannerItems(
          "https://pagepilot.fabbuilder.com/api/tenant/6655bc2b30a6760d8f897581/client/app-banners?filter[isActive]=true&filter[identifier]=TEST_ABOUT"),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: FutureBuilder<List<List<PagePilotBannerItem>>>(
              future: _bannerItemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No banners to display.'));
                }

                return Column(
                  children: [
                    Center(
                      child: Text('Running on: ${widget.platformVersion}\n'),
                    ),
                    ElevatedButton(
                      key: PagePilotKeys.keyBeacon,
                      onPressed: () {
                        widget.pagepilotPlugin.show(
                          context: context,
                          screen: "home",
                        );
                      },
                      child: const Text("Tap Me!"),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(key: PagePilotKeys.keyDialog, 'Dialog'),
                        Text(key: PagePilotKeys.keyTooltip, 'Tooltip'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text('tour')),
                    const SizedBox(height: 20),
                    PagePilotBanner(
                      items: snapshot.data![0],
                    ),
                    const SizedBox(height: 40),
                    PagePilotBanner(
                      items: snapshot.data![1],
                    )
                  ],
                );
              },
            ),
          ),
        ]));
  }
}
