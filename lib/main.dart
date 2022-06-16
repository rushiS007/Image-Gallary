import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('reloaded');
    return ScopedModel<_MyAppState>(
      model: _MyAppState(),
      child: MaterialApp(
          title: 'Photo Viewer',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: ScopedModelDescendant<_MyAppState>(
            builder: ((context, child, model) {
              return GallaryPage(title: "Image Gallary", model: model);
            }),
          )),
    );
  }
}

// class MyInheritedWidget extends InheritedWidget {
//   MyInheritedWidget({Key? key, required this.child, required this.state})
//       : super(key: key, child: child);

//   final Widget child;
//   final _MyAppState state;

//   static MyInheritedWidget? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<MyInheritedWidget>();
//   }

//   @override
//   bool updateShouldNotify(MyInheritedWidget oldWidget) {
//     return true;
//   }
// }

class _MyAppState extends Model {
  bool isTagging = false;

  List<PhotoState> photoStates = List.of(images.map((e) => PhotoState(url: e)));
  Set<String> tags = {'all', 'nature', 'dog'};

  static _MyAppState of(BuildContext context) {
    return ScopedModel.of<_MyAppState>(context);
  }

  void selectTag(String tag) {
    if (isTagging) {
      if (tag != 'all') {
        for (var element in photoStates) {
          if (element.selected) {
            element.tags.add(tag);
          }
        }
      }
      toggleTagging(null);
    } else {
      for (var element in photoStates) {
        element.display = tag == "all" ? true : element.tags.contains(tag);
      }
    }
    notifyListeners();
  }

  void toggleTagging(String? url) {
    isTagging = !isTagging;
    for (var element in photoStates) {
      if (isTagging && element.url == url) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    }
    notifyListeners();
  }

  void onPhotoSelect(String url, bool selected) {
    for (var element in photoStates) {
      if (element.url == url) {
        element.selected = selected;
      }
    }
    notifyListeners();
  }
}

const List<String> images = [
  "https://www.rd.com/wp-content/uploads/2018/02/30_Adorable-Puppy-Pictures-that-Will-Make-You-Melt_124167640_YamabikaY.jpg?fit=700,467",
  "https://tractive.com/blog/wp-content/uploads/2016/04/puppy-care-guide-for-new-parents-768x576.jpg",
  "https://www.readersdigest.ca/wp-content/uploads/2013/03/6-facts-to-know-before-owning-a-puppy.jpg",
  "https://dogtime.com/assets/uploads/2018/10/puppies-cover.jpg"
];

class PhotoState {
  String url;
  bool selected;
  bool? display;
  Set<String> tags = {};
  PhotoState({required this.url, this.selected = false, this.display, tags});
}

class GallaryPage extends StatelessWidget {
  final String title;
  final _MyAppState model;

  const GallaryPage({Key? key, required this.title, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: GridView.count(
          crossAxisCount: 2,
          primary: false,
          children: List.of(model.photoStates
              .where((element) => element.display ?? true)
              .map((e) => Photo(
                  state: e, model: _MyAppState.of(context))))),
      drawer: Drawer(
        child: ListView(
          children: List.of(model.tags.map((e) => ListTile(
                title: Text(e),
                onTap: () {
                  model.selectTag(e);
                  Navigator.pop(context);
                },
              ))),
        ),
      ),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final _MyAppState model;
  const Photo({Key? key, required this.state, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
        child: Image.network(
          state.url,
          height: 170,
          width: 170,
          fit: BoxFit.cover,
        ),
        onLongPress: () => model.toggleTagging(state.url),
      )
    ];
    if (model.isTagging) {
      children.add(Positioned(
        left: 20,
        top: 0,
        child: Theme(
            data: Theme.of(context)
                .copyWith(unselectedWidgetColor: Colors.grey[200]),
            child: Checkbox(
              value: state.selected,
              onChanged: (value) {
                model.onPhotoSelect(state.url, value!);
              },
              activeColor: Colors.white,
              checkColor: Colors.black,
            )),
      ));
    }
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }
}
