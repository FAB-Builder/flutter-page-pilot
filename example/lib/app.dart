import 'package:flutter/material.dart';
import 'package:pagepilot/pagepilot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pagepilot/widgets/page_pilot_banner.dart';
import 'package:pagepilot_example/page_pilot_keys.dart';

const String apiEndpoint = "https://pagepilot.fabbuilder.com/api/tenant/6655bc2b30a6760d8f897581/client/app-banners?filter[isActive]=true";

Future<List<PagePilotBannerItem>> fetchBannerItems() async {
  final url = Uri.parse(apiEndpoint);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final apiResponse = response.body;

    final responseJson = jsonDecode(apiResponse);
    final items = (responseJson['rows'] as List)
        .map((item) => PagePilotBannerItem.fromJson(item))
        .toList();
    //Only rendering HOME_BANNER
    final filteredItems = items.where((item) => item.identifier == "HOME_BANNER").toList();
    filteredItems.sort((a, b) => a.sequence.compareTo(b.sequence));
    return filteredItems;
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
  late Future<List<PagePilotBannerItem>> _bannerItemsFuture;

  @override
  void initState() {
    super.initState();
    _bannerItemsFuture = fetchBannerItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<PagePilotBannerItem>>(
          future: _bannerItemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final items = snapshot.data ?? [];

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
                  items: items,
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
