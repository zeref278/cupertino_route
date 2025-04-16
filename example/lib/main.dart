import 'package:cupertino_route/cupertino_route.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cupertino Route',
      onGenerateRoute: (settings) {
        return CupertinoRoute(
          builder: (context) => const MyHomePage(),
          physics: const ClampingScrollPhysics(),
        );
      },
      onGenerateInitialRoutes: (settings) {
        return [
          CupertinoRoute(
            builder: (context) => const MyHomePage(),
            physics: const ClampingScrollPhysics(),
          )
        ];
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            for (final platform in TargetPlatform.values)
              platform: const CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // home: ,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cupertino Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoRoute(
                    builder: (context) => const HorizontalListViewScreen(),
                    physics: const ClampingScrollPhysics(),
                  ),
                );
              },
              child: const Text('Horizontal list view'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoRoute(
                    builder: (context) => const TabBarViewScreen(),
                    physics: const ClampingScrollPhysics(),
                  ),
                );
              },
              child: const Text('Tab bar view'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoRoute(
                    builder: (context) => const PageViewScreen(),
                    swipeableBuilder: (context) => const EmptyScreen(),
                    physics: const ClampingScrollPhysics(),
                  ),
                );
              },
              child: const Text('Page view'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoRoute(
                    builder: (context) => const HorizontalListViewScreen(),
                    swipeableBuilder: (context) => const EmptyScreen(),
                    physics: const ClampingScrollPhysics(),
                  ),
                );
              },
              child: const Text('Swipeable right route'),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalListViewScreen extends StatelessWidget {
  const HorizontalListViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horizontal list view'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 500,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 150,
                  height: 500,
                  color: index % 2 == 0 ? Colors.black : Colors.red,
                );
              },
              itemCount: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class TabBarViewScreen extends StatefulWidget {
  const TabBarViewScreen({super.key});

  @override
  State<TabBarViewScreen> createState() => _TabBarViewScreenState();
}

class _TabBarViewScreenState extends State<TabBarViewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tab bar view'),
      ),
      body: Column(
        children: [
          TabBar(
            tabs: const [
              Text('Tab 1'),
              Text('Tab 2'),
              Text('Tab 3'),
            ],
            controller: _tabController,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: Colors.red,
                ),
                Container(
                  color: Colors.blue,
                ),
                Container(
                  color: Colors.green,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Empty screen'),
      ),
    );
  }
}

class PageViewScreen extends StatelessWidget {
  const PageViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.black,
            ),
            AspectRatio(
              aspectRatio: 1,
              child: PageView.builder(
                itemBuilder: (context, index) {
                  return Container(
                    color: index % 2 == 0 ? Colors.red : Colors.blue,
                  );
                },
                itemCount: 10,
              ),
            ),
            Container(
              height: 600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
