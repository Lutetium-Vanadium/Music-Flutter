import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focused_menu/modals.dart';

import 'package:music/global_providers/database.dart';
import 'package:music/bloc/data_bloc.dart';
import 'package:music/bloc/queue_bloc.dart';
import 'package:music/constants.dart';
import 'package:music/helpers/generateSubtitle.dart';
import 'package:music/models/models.dart';
import 'package:music/routes/widgets/CoverImage.dart';

class Artists extends StatefulWidget {
  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  List<ArtistData> _artists = [];

  @override
  void initState() {
    super.initState();
    getArtists();
  }

  getArtists() async {
    var artists = await DatabaseProvider.getDB(context).getArtists();

    if (!mounted) return;

    setState(() {
      _artists = artists.length > 0 ? artists : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width10 = MediaQuery.of(context).size.shortestSide / 10;

    return MultiBlocListener(
      listeners: [
        BlocListener<DataBloc, DataState>(
          listener: (_, state) {
            if (state is UpdateData) {
              getArtists();
            }
          },
        ),
        BlocListener<QueueBloc, QueueState>(
          listener: (_, state) {
            if (state.updateData) {
              getArtists();
            }
          },
        ),
      ],
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  EdgeInsets.only(left: width10 / 4 * 2, top: 30, bottom: 7),
              child:
                  Text('Artists', style: Theme.of(context).textTheme.headline3),
            ),
          ),
          _artists == null
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width10 / 2, vertical: 40),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: "There aren't any artists.\n\n",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        TextSpan(
                          text:
                              'Artists are automatically added when you download a song. Download songs by searching through the above Search Box.\n',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ]),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(0.3 * width10),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          (4.1 * width10) / (4.1 * width10 + 3 * rem),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var artist = _artists[index];

                        var mozaic = artist.images.length == 4;

                        return CoverImage(
                          image: mozaic ? null : artist.images[0],
                          images: mozaic ? artist.images : null,
                          title: artist.name,
                          subtitle: generateSubtitle(
                              type: 'Artist', numSongs: artist.numSongs),
                          isBig: true,
                          tag: artist.name,
                          onClick: () {
                            Navigator.of(context)
                                .pushNamed('/artist', arguments: artist);
                          },
                          focusedMenuItems: [
                            FocusedMenuItem(
                              onPressed: () async {
                                var songs =
                                    await DatabaseProvider.getDB(context)
                                        .getSongs(
                                            where: 'artist LIKE ?',
                                            whereArgs: [artist.name]);

                                BlocProvider.of<QueueBloc>(context)
                                    .add(EnqueueSongs(songs: songs));
                              },
                              title: Text('Play'),
                              trailingIcon: Icon(Icons.playlist_play),
                              backgroundColor: Colors.transparent,
                            ),
                          ],
                        );
                      },
                      childCount: _artists.length,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
