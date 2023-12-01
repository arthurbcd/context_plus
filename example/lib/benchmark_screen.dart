import 'package:context_watch/context_watch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rxdart/streams.dart';

enum BenchmarkDataType {
  valueListenable,
  future,
  stream,
  valueStream,
}

enum BenchmarkListenerType {
  contextWatch,
  streamBuilder,
}

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({
    super.key,
    this.singleObservableSubscriptionsCount = 500,
    this.singleObservableSubscriptionCountOptions = const {
      0,
      100,
      500,
      1000,
      2000,
      5000,
    },
    this.tilesCount = 500,
    this.tileCountOptions = const {
      0,
      100,
      500,
      1000,
      2000,
      5000,
    },
    this.observablesPerTile = 2,
    this.observablesPerTileOptions = const {
      0,
      1,
      2,
      3,
      5,
      10,
      20,
    },
    this.subscriptionsPerTileObservable = 1,
    this.subscriptionsPerTileObservableOptions = const {
      1,
      2,
      3,
      5,
      10,
      20,
    },
    this.dataType = BenchmarkDataType.valueStream,
    this.listenerType = BenchmarkListenerType.contextWatch,
    this.runOnStart = true,
    this.showPerformanceOverlay = true,
    this.visualize = true,
  });

  final int singleObservableSubscriptionsCount;
  final Set<int> singleObservableSubscriptionCountOptions;

  final int tilesCount;
  final Set<int> tileCountOptions;

  final int observablesPerTile;
  final Set<int> observablesPerTileOptions;

  final int subscriptionsPerTileObservable;
  final Set<int> subscriptionsPerTileObservableOptions;

  final BenchmarkDataType dataType;
  final BenchmarkListenerType listenerType;

  final bool runOnStart;
  final bool showPerformanceOverlay;
  final bool visualize;

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen> {
  var _tilesContainerKey = UniqueKey();

  late var _singleObservableSubscriptionsCount =
      widget.singleObservableSubscriptionsCount;
  late var _tilesCount = widget.tilesCount;
  late var _observablesPerTile = widget.observablesPerTile;
  late var _subscriptionsPerTileObservable =
      widget.subscriptionsPerTileObservable;

  late var _dataType = widget.dataType;
  late var _listenerType = widget.listenerType;
  late var _runBenchmark = widget.runOnStart;

  late var _visualize = widget.visualize;

  final _stream = Stream.periodic(const Duration(milliseconds: 1), (i) => i)
      .asBroadcastStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Benchmark'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTilesCountSelector(),
              _buildDataTypeSelector(),
              _buildListenerSelector(),
              _buildTotalSubscriptionsInfo(),
              _buildControlButtons(),
            ],
          ),
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          left: 16,
          top: 16,
          right: 16,
          bottom: 16 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          children: [
            Expanded(
              child: _runBenchmark
                  ? _buildBenchmarkTilesGrid()
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _singleObservableSubscriptionsCount; i++)
              _buildSingleObservableObserver(i),
            if (widget.showPerformanceOverlay) _buildPerformanceOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildBenchmarkTilesGrid() {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(builder: (context, constraints) {
        int tileSize = 24;
        var tilesPerRow = constraints.maxWidth ~/ tileSize;
        var rowsCount = _tilesCount ~/ tilesPerRow;
        var rowsHeight = rowsCount * tileSize;
        while (rowsHeight > constraints.maxHeight) {
          tileSize -= 1;
          if (tileSize == 0) {
            break;
          }
          tilesPerRow = constraints.maxWidth ~/ tileSize;
          rowsCount = _tilesCount ~/ tilesPerRow;
          rowsHeight = rowsCount * tileSize;
        }

        return Wrap(
          key: _tilesContainerKey,
          children: [
            for (var i = 0; i < _tilesCount; i++) _buildTile(i, tileSize),
          ],
        );
      }),
    );
  }

  Widget _buildTilesCountSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Tiles count:'),
          DropdownButton<int>(
            isDense: true,
            value: _tilesCount,
            onChanged: (value) => setState(() {
              _tilesCount = value!;
              _tilesContainerKey = UniqueKey();
            }),
            items: [
              for (final tilesCount in widget.tileCountOptions)
                DropdownMenuItem(
                  value: tilesCount,
                  child: Text(tilesCount.toString()),
                ),
            ],
          ),
          const Text('Single observable subscriptions:'),
          DropdownButton<int>(
            isDense: true,
            value: _singleObservableSubscriptionsCount,
            onChanged: (value) => setState(() {
              _singleObservableSubscriptionsCount = value!;
              _tilesContainerKey = UniqueKey();
            }),
            items: [
              for (final singleObservableSubscriptionsCount
                  in widget.singleObservableSubscriptionCountOptions)
                DropdownMenuItem(
                  value: singleObservableSubscriptionsCount,
                  child: Text(singleObservableSubscriptionsCount.toString()),
                ),
            ],
          ),
          const Text('Observables per tile:'),
          DropdownButton<int>(
            isDense: true,
            value: _observablesPerTile,
            onChanged: (value) => setState(() {
              _observablesPerTile = value!;
              _tilesContainerKey = UniqueKey();
            }),
            items: [
              for (final observablesPerTile in widget.observablesPerTileOptions)
                DropdownMenuItem(
                  value: observablesPerTile,
                  child: Text(observablesPerTile.toString()),
                ),
            ],
          ),
          const Text('Subscriptions per tile observable:'),
          DropdownButton<int>(
            isDense: true,
            value: _subscriptionsPerTileObservable,
            onChanged: (value) => setState(() {
              _subscriptionsPerTileObservable = value!;
              _tilesContainerKey = UniqueKey();
            }),
            items: [
              for (final subscriptionsPerTileObservable
                  in widget.subscriptionsPerTileObservableOptions)
                DropdownMenuItem(
                  value: subscriptionsPerTileObservable,
                  child: Text(subscriptionsPerTileObservable.toString()),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeSelector() {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Text('Data type:'),
        const SizedBox(width: 16),
        DropdownButton<BenchmarkDataType>(
          isDense: true,
          value: _dataType,
          onChanged: (value) => setState(() {
            _dataType = value!;
            _tilesContainerKey = UniqueKey();
          }),
          items: const [
            DropdownMenuItem(
              value: BenchmarkDataType.stream,
              child: Text('Stream'),
            ),
            DropdownMenuItem(
              value: BenchmarkDataType.valueStream,
              child: Text('ValueStream'),
            ),
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildListenerSelector() {
    return Row(
      children: [
        const SizedBox(width: 16),
        const Text('Listen using:'),
        const SizedBox(width: 16),
        DropdownButton<BenchmarkListenerType>(
          isDense: true,
          value: _listenerType,
          onChanged: (value) => setState(() {
            _listenerType = value!;
            _tilesContainerKey = UniqueKey();
          }),
          items: [
            if (_dataType == BenchmarkDataType.stream ||
                _dataType == BenchmarkDataType.valueStream) ...const [
              DropdownMenuItem(
                value: BenchmarkListenerType.contextWatch,
                child: Text('Stream.watch(context)'),
              ),
              DropdownMenuItem(
                value: BenchmarkListenerType.streamBuilder,
                child: Text('StreamBuilder'),
              ),
            ],
          ],
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTotalSubscriptionsInfo() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      child: Text(
        'Total subscriptions: ${_singleObservableSubscriptionsCount + _tilesCount * _observablesPerTile * _subscriptionsPerTileObservable}\n'
        '$_singleObservableSubscriptionsCount single observable subscriptions\n'
        '+ $_tilesCount tiles x $_observablesPerTile observables x $_subscriptionsPerTileObservable subscriptions',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      children: [
        const SizedBox(width: 16),
        ElevatedButton(
          key: const Key('start'),
          onPressed: !_runBenchmark
              ? () => setState(() {
                    _tilesContainerKey = UniqueKey();
                    _runBenchmark = true;
                  })
              : null,
          child: const Text('Start'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          key: const Key('stop'),
          onPressed: _runBenchmark
              ? () => setState(() {
                    _tilesContainerKey = UniqueKey();
                    _runBenchmark = false;
                  })
              : null,
          child: const Text('Stop'),
        ),
        const SizedBox(width: 16),
        Checkbox(
          value: _visualize,
          onChanged: (value) => setState(() {
            _visualize = value!;
            _tilesContainerKey = UniqueKey();
          }),
        ),
        const Text('Visualize'),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTile(int i, int tileSize) {
    return SizedBox(
      key: ValueKey(i),
      width: tileSize.toDouble(),
      height: tileSize.toDouble(),
      child: _Tile(
        key: ValueKey('tile$i'),
        index: i,
        dataType: _dataType,
        listenerType: _listenerType,
        visualize: _visualize,
      ),
    );
  }

  Widget _buildSingleObservableObserver(int index) {
    return switch (_listenerType) {
      BenchmarkListenerType.contextWatch => Builder(
          key: ValueKey(index),
          builder: (context) {
            _stream.watch(context);
            return const SizedBox.shrink();
          },
        ),
      BenchmarkListenerType.streamBuilder => StreamBuilder(
          key: ValueKey(index),
          stream: _stream,
          builder: (context, _) => const SizedBox.shrink(),
        ),
    };
  }

  Widget _buildPerformanceOverlay() {
    return SizedBox(
      height: 36,
      child: PerformanceOverlay(
        optionsMask:
            1 << PerformanceOverlayOption.displayRasterizerStatistics.index |
                1 << PerformanceOverlayOption.displayEngineStatistics.index,
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.index,
    required this.dataType,
    required this.listenerType,
    required this.visualize,
  });

  final int index;
  final BenchmarkDataType dataType;
  final BenchmarkListenerType listenerType;
  final bool visualize;

  @override
  Widget build(BuildContext context) {
    if (dataType == BenchmarkDataType.stream ||
        dataType == BenchmarkDataType.valueStream) {
      return _StreamsProvider(
        key: ValueKey(index),
        useValueStream: dataType == BenchmarkDataType.valueStream,
        initialDelay: Duration(milliseconds: 4 * index),
        delay: const Duration(milliseconds: 48),
        builder: (context, colorIndexStream, scaleIndexStream) {
          if (listenerType == BenchmarkListenerType.contextWatch) {
            return ItemContextWatch(
              colorIndexStream: colorIndexStream,
              scaleIndexStream: scaleIndexStream,
              visualize: visualize,
            );
          }
          return ItemStreamBuilder(
            initialColorIndex: dataType == BenchmarkDataType.valueStream
                ? (colorIndexStream as ValueStream<int>).value
                : null,
            colorIndexStream: colorIndexStream,
            initialScaleIndex: dataType == BenchmarkDataType.valueStream
                ? (scaleIndexStream as ValueStream<int>).value
                : null,
            scaleIndexStream: scaleIndexStream,
            visualize: visualize,
          );
        },
      );
    }

    return const Placeholder();
  }
}

class ItemContextWatch extends StatelessWidget {
  const ItemContextWatch({
    super.key,
    required this.colorIndexStream,
    required this.scaleIndexStream,
    required this.visualize,
  });

  final Stream<int> colorIndexStream;
  final Stream<int> scaleIndexStream;
  final bool visualize;

  @override
  Widget build(BuildContext context) {
    return _build(
      colorIndexSnapshot: colorIndexStream.watch(context),
      scaleIndexSnapshot: scaleIndexStream.watch(context),
      visualize: visualize,
    );
  }
}

class ItemStreamBuilder extends StatelessWidget {
  const ItemStreamBuilder({
    super.key,
    required this.initialColorIndex,
    required this.colorIndexStream,
    required this.initialScaleIndex,
    required this.scaleIndexStream,
    required this.visualize,
  });

  final int? initialColorIndex;
  final Stream<int> colorIndexStream;
  final int? initialScaleIndex;
  final Stream<int> scaleIndexStream;
  final bool visualize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: initialColorIndex,
      stream: colorIndexStream,
      builder: (context, colorIndexSnapshot) => StreamBuilder(
        initialData: initialScaleIndex,
        stream: scaleIndexStream,
        builder: (context, scaleIndexSnapshot) => _build(
          colorIndexSnapshot: colorIndexSnapshot,
          scaleIndexSnapshot: scaleIndexSnapshot,
          visualize: visualize,
        ),
      ),
    );
  }
}

class _StreamsProvider extends StatefulWidget {
  const _StreamsProvider({
    super.key,
    required this.builder,
    required this.initialDelay,
    required this.delay,
    required this.useValueStream,
  });

  final Widget Function(
    BuildContext context,
    Stream<int> colorIndexStream,
    Stream<int> scaleIndexStream,
  ) builder;
  final Duration initialDelay;
  final Duration delay;
  final bool useValueStream;

  @override
  State<_StreamsProvider> createState() => _StreamsProviderState();
}

class _StreamsProviderState extends State<_StreamsProvider> {
  late Stream<int> colorIndexStream;
  late Stream<int> scaleIndexStream;

  @override
  void initState() {
    super.initState();
    final initialDelay = widget.initialDelay;
    final delay = widget.delay;
    colorIndexStream = Stream.fromFuture(Future.delayed(initialDelay))
        .asyncExpand((_) => Stream<int>.periodic(delay, (i) => i));
    scaleIndexStream = Stream.fromFuture(Future.delayed(initialDelay))
        .asyncExpand((_) => Stream<int>.periodic(delay, (i) => i));
    if (widget.useValueStream) {
      colorIndexStream = colorIndexStream.shareValueSeeded(0);
      scaleIndexStream = scaleIndexStream.shareValueSeeded(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, colorIndexStream, scaleIndexStream);
  }
}

Widget _build({
  required AsyncSnapshot<int> colorIndexSnapshot,
  required AsyncSnapshot<int> scaleIndexSnapshot,
  required bool visualize,
}) {
  if (!visualize) {
    return const SizedBox.shrink();
  }

  const loadingColor = Color(0xFFFFFACA);

  final child = switch (colorIndexSnapshot) {
    AsyncSnapshot(hasData: true, requireData: final colorIndex) =>
      ColoredBox(color: _colors[colorIndex % _colors.length]),
    AsyncSnapshot(hasError: false) => const ColoredBox(color: loadingColor),
    AsyncSnapshot(hasError: true) => const ColoredBox(color: Colors.red),
  };

  final scaledChild = switch (scaleIndexSnapshot) {
    AsyncSnapshot(hasData: true, requireData: final scaleIndex) =>
      Transform.scale(
        scale: _scales[scaleIndex % _scales.length],
        child: child,
      ),
    AsyncSnapshot(hasError: false) => const ColoredBox(color: loadingColor),
    AsyncSnapshot(hasError: true) => const ColoredBox(color: Colors.red),
  };

  return scaledChild;
}

final _colors = _generateGradient(Colors.white, Colors.grey.shade400, 32);
List<Color> _generateGradient(Color startColor, Color endColor, int steps) {
  List<Color> gradientColors = [];
  int halfSteps = steps ~/ 2; // integer division to get half the steps
  for (int i = 0; i < halfSteps; i++) {
    double t = i / (halfSteps - 1);
    gradientColors.add(Color.lerp(startColor, endColor, t)!);
  }
  for (int i = 0; i < halfSteps; i++) {
    double t = i / (halfSteps - 1);
    gradientColors.add(Color.lerp(endColor, startColor, t)!);
  }
  return gradientColors;
}

final _scales = _generateScales(0.5, 0.9, 32);
List<double> _generateScales(double startScale, double endScale, int steps) {
  List<double> scales = [];
  int halfSteps = steps ~/ 2; // integer division to get half the steps
  for (int i = 0; i < halfSteps; i++) {
    double t = i / (halfSteps - 1);
    scales.add(startScale + (endScale - startScale) * t);
  }
  for (int i = 0; i < halfSteps; i++) {
    double t = i / (halfSteps - 1);
    scales.add(endScale + (startScale - endScale) * t);
  }
  return scales;
}
